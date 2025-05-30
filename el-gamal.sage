# ElGamal Encryption Scheme Implementation in SageMath


class ElGamal:
    def __init__(self, group, generator, order):
        self.group = group
        self.g = generator
        self.q = order
        
    
    def keygen(self):
        self.sk = IntegerModRing(self.q).random_element()
        self.pk = self.g ** self.sk

    def encrypt(self, m):
        r = IntegerModRing(self.q).random_element()
        c1 = m * (self.pk ** r)
        c2 = self.g ** r
        return (c1, c2)

    def decrypt(self, ciphertext):
        c1, c2 = ciphertext
        return c2 / (c1 ** self.sk)  # Assuming sk is the secret key of the group
    
    @staticmethod
    def multiply_ciphertexts(c, d):
        (c1, c2) = c
        (d1, d2) = d
        return (c1 * d1, c2 * d2)

if __name__ == "__main__":
    while True:
        q = random_prime(2**16, proof=True)
        p = 2 * q + 1
        if p.is_prime():
            break
    group = IntegerModRing(p)
    g = group.random_element()
    g = g**2

    elgamal = ElGamal(group, g, q)
    elgamal.keygen()

    m1 = group.random_element()
    m1 = m1**2  
    ciphertext1 = elgamal.encrypt(m1)
    m2 = group.random_element()
    m2 = m2**2
    ciphertext2 = elgamal.encrypt(m2)
    combined_ciphertext = ElGamal.multiply_ciphertexts(ciphertext1, ciphertext2)
    decrypted_combined_message = elgamal.decrypt(combined_ciphertext)

    print(f"Original message: {m1}, {m2}")
    print(f"Ciphertext1: {ciphertext1}")
    print(f"Ciphertext2: {ciphertext2}")
    print(f"decrypted_combined_message: {decrypted_combined_message}")

