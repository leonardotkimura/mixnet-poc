import math 


class Verifier:
    def __init__(self, p, q, generator, h_list):
        self.p = p
        self.q = q
        self.g = generator
        self.h_list = h_list

        pass

    def verifyProof(self, proof, entry_list, out_list, pk, dbg):
        N = len(entry_list)
        (t, s, c_list, c_hat_list) = proof
        s_hat_list = s[4]
        s_prime_list = s[5]

        u_list = []
        for i in range(N):
            statement = str(((entry_list, out_list, c_list), i))
            challenge = Hash.text_to_integer(statement,  self.q)
            u_list.append(challenge)
        
        print(f"u_list - Verifier: {u_list}")

        c_bar = prod(c_list) * prod(self.h_list).inverse() % self.p
        u = prod(u_list) % self.q
        c_hat = (c_hat_list[N-1]  * (c_list[0] ** u).inverse()) % self.p
        c_tilde = prod(c_list[i] ** u_list[i] for i in range(N)) % self.p
        a_prime = prod(entry_list[i][0] ** u_list[i] for i in range(N)) % self.p
        b_prime = prod(entry_list[i][1] ** u_list[i] for i in range(N)) % self.p

        y = (entry_list, out_list, c_list, c_hat_list, pk)
        statement = str((y, t))
        challenge = Hash.text_to_integer(statement, self.q)

        t_prime_0 = ((c_bar ** challenge).inverse() * (self.g ** s[0])) % self.p
        t_prime_1 = ((c_hat ** challenge).inverse() * (self.g ** s[1])) % self.p
        t_prime_2 = ((c_tilde ** challenge).inverse() * (self.g ** s[2]) * prod(self.h_list[i] ** s_prime_list[i] for i in range(N))) % self.p
        t_prime_3_0 = ((a_prime ** challenge).inverse() * (pk ** s[3]).inverse()) * prod(out_list[i][0] ** s_prime_list[i] for i in range(N)) % self.p
        t_prime_3_1 = ((b_prime ** challenge).inverse() * (self.g ** s[3]).inverse()) * prod(out_list[i][1] ** s_prime_list[i] for i in range(N)) % self.p        

        # breakpoint()
        aux1 = (b_prime ** challenge).inverse() * prod(out_list[i][1] ** (challenge * dbg['u_prime_list'][i]) for i in range(N))
        aux2 =  (self.g ** (challenge * dbg['r_prime'])).inverse()
        aux3 = (self.g ** dbg['w_list'][3]).inverse() * prod(out_list[i][1] ** dbg['w_prime_list'][i] for i in range(N))
        print(f"aux1: {aux1}")
        print(f"aux2: {aux2}")

        breakpoint()

        print(f"b_prime: {b_prime}")
        print(f"challenge: {challenge}")
        print(f"pk: {pk}")
        print(f"b_prime ** (-challenge): {(b_prime ** (-challenge))}")
        print(f"b_prime ** (-challenge): {pow(b_prime,-challenge, self.p)}")
        print(f"b_prime ** (-challenge): {pow((b_prime ** challenge), -1, self.p)}")
        # print(f"b_prime ** (-challenge): {inverse_mod(b_prime ** challenge, self.p)}")

        

        t_hat_prime_list = []
        for i in range(N):
            prev_c_hat = c_hat if i == 0 else c_hat_list[i-1]
            t_hat_prime = ((c_hat_list[i] ** challenge).inverse() * (self.g ** s_hat_list[i]) * (prev_c_hat ** s_prime_list[i])) % self.p
            t_hat_prime_list.append(t_hat_prime)
        
        assert t[0] == t_prime_0, "t[0] does not match t_prime_0"
        assert t[1] == t_prime_1, "t[1] does not match t_prime_1"
        assert t[2] == t_prime_2, "t[2] does not match t_prime_2"
        assert t[3][0] == t_prime_3_0, f"t[3][0] does not match t_prime_3_0: {t[3][0]} != {t_prime_3_0}"
        assert t[3][1] == t_prime_3_1, f"t[3][1] does not match t_prime_3_1: {t[3][1]} != {t_prime_3_1}"
        t_hat_list = t[4]
        for i in range(N):
            assert t_hat_list[i] == t_hat_prime_list[i], f"t[4][{i}] does not match t_hat_prime_list[{i}]"
    
        return True, debug