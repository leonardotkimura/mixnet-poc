N = 5

def gen_params():
    while True:
        q = random_prime(2**16, proof=True)
        p = 2 * q + 1
        if p.is_prime():
            break
    group = IntegerModRing(p)
    g = group.random_element()
    g = g**2

    h_list = []
    for i in range(N):
        h = group.random_element()
        h = h**2
        h_list.append(h)

    return p, q, group, g, h_list

p, q, group, g, h_list = gen_params()

elgamal = ElGamal(group, g, q)
elgamal.keygen()

plaintext_list = []
ciphertext_list_1 = []
ciphertext_list_2 = []

for i in range(N):
    m = group.random_element()
    m = m**2  
    ciphertext = elgamal.encrypt(m)
    plaintext_list.append(m)
    ciphertext_list_1.append(ciphertext)

shuffle = Shuffle(group, p, q, g, h_list, elgamal.pk)
(ciphertext_list_2, random_list, phi) = shuffle.genShuffle(ciphertext_list_1, elgamal.pk)
proof = shuffle.genProof(ciphertext_list_1, ciphertext_list_2, random_list, phi)

print(f"Ciphertext1: {ciphertext_list_1}")
print(f"Ciphertext2: {ciphertext_list_2}")
print(f"Random list: {random_list}")
print(f"Permutation: {phi}")
print(f"Proof: {proof}")

verifier = Verifier(p, q, g, h_list)
result= verifier.verifyProof(proof, ciphertext_list_1, ciphertext_list_2, elgamal.pk)

