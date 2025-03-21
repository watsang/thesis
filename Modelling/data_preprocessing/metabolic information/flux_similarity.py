# Old file to parse and process files obtained from the seed viewer
# scrape for useful parts

import numpy as np
import pandas as pd
import re
# from pandas.io.parsers import ExcelFile

def KL_MVN(M1, M2):
    mu1, S1 = M1
    mu2, S2 = M2
    k = S1.shape[0]
    S1_inv = np.linalg.inv(S1)
    first = np.sum([np.dot(S2[:,i],S1_inv[i,:]) for i in range(k)])
    Dmu = mu2-mu1
    second = float(np.dot(Dmu.T, np.dot(S1_inv, Dmu)))
    last = log_det(S1)-log_det(S2)
    return 0.5*(first + second - k - last)

def log_det(M):
    return np.sum(np.log(np.linalg.eigvals(M))).real
    
def compare_metabolism(Sp1, Sp2, sigma=0.01):
    rset_1 = list(Sp1.stoichM.columns)
    rset_2 = list(Sp2.stoichM.columns)
    r_shared = list((set(rset_1) & set(rset_2)))
    r_ind_1 = [rset_1.index(r) for r in r_shared]
    r_ind_2 = [rset_2.index(r) for r in r_shared]
    mu1, S1 = Sp1.posterior_model(sigma)
    mu2, S2 = Sp2.posterior_model(sigma)
    return KL_MVN((mu1[r_ind_1], S1[r_ind_1,:][:,r_ind_1]), (mu2[r_ind_2], S2[r_ind_2,:][:,r_ind_2]))
    
    
class Reaction:
    '''
    function to parse a reaction obtained from the the Seed annotation
    '''
    def __init__(self, equation, DG, DG_std):
        self.eq = equation
        self.left_stoich = self.parse_reaction(equation.split('=')[0])
        self.right_stoich = self.parse_reaction(equation.split('=')[1])
        if DG > 1000:
            self.DG = 0
            self.DG_std = 10
        elif np.isnan(DG):
            self.DG = 50
            self.DG_std = 1
        else:
            self.DG = DG
            self.DG_std = DG_std
        self.exchanged = self.exchanged_compounds(equation)
        
    def parse_reaction(self,r):
        compounds = re.findall('cpd\d+',r)
        compounds_stoich = re.findall(r'\(\d+\) cpd\d+',r)
        stoich_dict = {re.findall('cpd\d+',c)[0]:int(re.findall(r'\d+',c)[0]) for c in compounds_stoich}
        stoichiometry = {}
        for c in compounds:
            if c in stoich_dict:
                stoichiometry[c] = stoich_dict[c]
            else:
                stoichiometry[c] = 1
        return stoichiometry
    
    def exchanged_compounds(self,r):
        compounds = re.findall('cpd\d+',r)
        exchanged = re.findall(r'cpd\d+\[e\]',r)
        exch = []
        for e in exchanged:
            for c in compounds:
                if re.match(c, e):
                    exch.append(c)
        return exch
        
        
class Stoichiometric_model:
    """
construct a metabolic model from the Seed file
    """
    def __init__(self, DF):
        self.N_reactions = DF.shape[0]
        self.reactions = {DF.DATABASE[i]:Reaction(DF.EQUATION[i], DF['DELTAG (kcal/mol)'][i], DF['DELTAG ERROR (kcal/mol)'][i]) for i in range(self.N_reactions)} 
        self.make_compounds_list()
        self.make_SM()
        self.list_exchanged_compounds()
        
    def make_compounds_list(self):
        compounds = []
        for r in self.reactions.values():
            compounds += r.right_stoich.keys()
            compounds += r.left_stoich.keys()
        self.compounds = list(set(compounds))
        self.N_compounds = len(self.compounds)
        
    def make_SM(self):
        S = np.zeros((self.N_compounds, self.N_reactions))
        for j in range(self.N_reactions):
            c_left = self.reactions.values()[j].left_stoich
            for c in c_left.keys():
                i = self.compounds.index(c)
                S[i,j] = -c_left[c]
            c_right = self.reactions.values()[j].right_stoich
            for c in c_right.keys():
                i = self.compounds.index(c)
                S[i,j] = c_right[c]
        self.stoichM = pd.DataFrame(S, index = self.compounds, columns = self.reactions.keys())
    
    def list_exchanged_compounds(self):
        self.exchanged = []
        self.not_exchanged = self.compounds + []
        for r in self.reactions.values():
            for e in r.exchanged:
                if e not in self.exchanged:
                    self.exchanged.append(e)
                if e in self.not_exchanged:
                    self.not_exchanged.remove(e)
        self.not_exch_ind = [self.compounds.index(r) for r in self.not_exchanged]  
        
    def return_S_pss(self):
        return self.stoichM.values[self.not_exch_ind,:]
    
    def prior_model(self, inv_cov = False):
        mean_prior = np.reshape([r.DG for r in self.reactions.values()], (-1,1))
        if inv_cov:
            cov_prior = np.diag([r.DG_std**(-2) for r in self.reactions.values()])
        else:
            cov_prior = np.diag([r.DG_std**(2) for r in self.reactions.values()])
        return mean_prior, cov_prior
    
    def posterior_model(self, sigmasq):
        S_pss = self.return_S_pss()
        mu, Lambda = self.prior_model(True)
        Sigma = np.linalg.inv((Lambda + np.dot(S_pss.T, S_pss)/sigmasq))
        mu_post = np.dot(Sigma, np.dot(Lambda, mu))
        return mu_post, Sigma
        
if __name__=="__main__":
    import matplotlib.pyplot as plt
    
    n = 20
    
    Seed_list = ['Seed_files/M_'+str(i)+'.xls' for i in range(1,n+1)]



    models_list = []

    for f in Seed_list:
        xls = pd.io.parsers.ExcelFile(f)
        reactions = xls.parse('Reactions', index_col=None, na_values=['NA'])
        models_list.append(Stochiometric_model(reactions))
    
    for s in range(-4,4):#[10**i for i in range(-4,3) ]:
        Sims = np.zeros((n,n))
    
        for i in range(n):
            print '%s/%s' %(i+1,n)
            for j in range(n):
                Sims[i,j] = compare_metabolism(models_list[i],models_list[j],10.0**s)
    

        #print Sims
    
        plt.imshow(np.log(Sims+1), interpolation='nearest')
        plt.savefig('Flux_similarity_'+str(s))
    
        np.savetxt('Flux_similarities_log_'+str(s)+'.txt', np.log(Sims+1))
    
        np.savetxt('Flux_similarities_'+str(s)+'.txt', Sims)