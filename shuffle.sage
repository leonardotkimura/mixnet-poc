import numpy as np
import math

class Shuffle:
    def __init__(self, group, p, q, generator, h_list, pk):
        self.group = group
        self.p = p
        self.q = q
        self.g = generator
        self.h_list = h_list
        self.pk = pk
    
    def genShuffle(self, entry_list, pk):
        phi = Shuffle.genPermutation(len(entry_list))
        reencrypted_list = []
        random_list = []
        for c in entry_list:
            r = IntegerModRing(self.q).random_element()
            a = c[0]*pk**r
            b = c[1]*self.g**r
            reencrypted_list.append((a, b))
            random_list.append(r)
        shuffled_list = [reencrypted_list[i] for i in phi]
        return (shuffled_list, random_list, phi)

    
    @staticmethod
    def genPermutation(n):
        phi = np.array(range(n))
        phi = np.random.permutation(phi)
        return phi
    

    def genProof(self, entry_list, out_list, r_prime_list, phi):
        N = len(entry_list)
        (c_list, r_list) = self.genCommitment(phi)

        u_list = []
        for i in range(N):
            statement = ((entry_list, out_list, c_list), i)
            statement = str(statement)
            challenge = Hash.text_to_integer(statement, self.q)
            u_list.append(challenge)
        u_prime_list = [u_list[i] for i in phi]

        (c_hat_list, r_hat_list) = self.genCommitmentChain(self.h_list[0], u_prime_list)
    
        r_bar = sum(r_list) % self.q

        v_list = np.empty(N, dtype=object)
        v_list[N-1] = 1
        for i in range(N-2, -1, -1):
            v_list[i] = u_prime_list[i+1] * v_list[i+1] % self.q
        
        r_hat = sum(r_hat_list[i] * v_list[i] for i in range(N)) % self.q
        r_tilde = sum(r_list[i] * u_list[i] for i in range(N)) % self.q
        r_prime = sum(r_prime_list[i] * u_list[i] for i in range(N)) % self.q

        w_list = []
        for i in range(4):
            w = IntegerModRing(self.q).random_element()
            w_list.append(w)
        
        w_hat_list = []
        w_prime_list = []
        for i in range(N):
            w_hat = IntegerModRing(self.q).random_element()
            w_hat_list.append(w_hat)
            w_prime = IntegerModRing(self.q).random_element()
            w_prime_list.append(w_prime)
        

        t0 = self.g**w_list[0] % self.p
        t1 = self.g**w_list[1] % self.p
        t2 = self.g**w_list[2] * prod(self.h_list[i] ** w_prime_list[i] for i in range(N)) % self.p
        t3_0 = ((self.pk ** w_list[3]).inverse() * prod(out_list[i][0] ** w_prime_list[i] for i in range(N))) % self.p
        t3_1 = ((self.g ** w_list[3]).inverse() * prod(out_list[i][1] ** w_prime_list[i] for i in range(N))) % self.p

        c_hat_0 = self.h_list[0]
        t_hat_list = []
        for i in range(N):
            if i == 0:
                t_hat = ((self.g ** w_hat_list[i]) * (c_hat_0 ** w_prime_list[i])) % self.p
            else:
                t_hat = ((self.g ** w_hat_list[i]) * (c_hat_list[i-1] ** w_prime_list[i])) % self.p
            t_hat_list.append(t_hat)
        
        y = (entry_list, out_list, c_list, c_hat_list, self.pk)
        t = (t0, t1, t2, (t3_0, t3_1), t_hat_list)

        statement = str((y, t))
        challenge = Hash.text_to_integer(statement, self.q)

        s0 = (w_list[0] + challenge * r_bar) % self.q
        s1 = (w_list[1] + challenge * r_hat) % self.q
        s2 = (w_list[2] + challenge * r_tilde) % self.q
        s3 = (w_list[3] + challenge * r_prime) % self.q

        s_hat_list = []
        s_prime_list = []
        for i in range(N):
            s_hat = (w_hat_list[i] + challenge * r_hat_list[i]) % self.q
            s_hat_list.append(s_hat)
            s_prime = (w_prime_list[i] + challenge * u_prime_list[i]) % self.q
            s_prime_list.append(s_prime)
        
        s = (s0, s1, s2, s3, s_hat_list, s_prime_list)
        proof = (t, s, c_list, c_hat_list)

        return proof

    def genCommitment(self, phi):
        r_list = np.empty(len(phi), dtype=object)
        c_list = np.empty(len(phi), dtype=object)
        for i in range(len(phi)):
            r = IntegerModRing(self.q).random_element()
            c = (self.g**r) * self.h_list[i]
            index = phi[i]
            r_list[index] = r
            c_list[index] = c
        return (c_list.tolist(), r_list.tolist())

    def genCommitmentChain(self, c0, u_list):
        c_list = []
        r_list = []
        for i in range(len(u_list)):
            u = u_list[i]
            r = IntegerModRing(self.q).random_element()
            if i == 0:
                c = (self.g**r) * (c0**u)
            else:
                c = (self.g**r) * (c_list[i-1]**u)
            c_list.append(c)
            r_list.append(r)
        return (c_list, r_list)