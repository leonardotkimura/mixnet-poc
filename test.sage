N = 10

class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

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

print(bcolors.OKGREEN + "\n\n1) Generating random plaintexts and encrypting them..." + bcolors.ENDC)

for i in range(1, N+1):  # start from 1 to N
    m = group(i)
    m = m**2  
    ciphertext = elgamal.encrypt(m)
    plaintext_list.append(m)
    ciphertext_list_1.append(ciphertext)

print(f"Plaintext: {plaintext_list}")
print(f"Encrypted: {ciphertext_list_1}")


print(bcolors.OKGREEN + "\n2) Shuffling the ciphertexts and generating the proofs..." + bcolors.ENDC)
shuffle = Shuffle(group, p, q, g, h_list, elgamal.pk)
(ciphertext_list_2, random_list, phi) = shuffle.genShuffle(ciphertext_list_1, elgamal.pk)
proof = shuffle.genProof(ciphertext_list_1, ciphertext_list_2, random_list, phi)

print(f"Ciphertext after shuffling: {ciphertext_list_2}")
print(f"Proof: {proof}")

print(bcolors.OKGREEN + "\n3) Decrypting the ciphertexts..." + bcolors.ENDC)
decrypted_list = []
for c in ciphertext_list_2:
    decrypted = elgamal.decrypt(c)
    decrypted_list.append(decrypted)
print(f"Decrypted: {decrypted_list}")

print(bcolors.OKGREEN + "\n4) Verifying the proof..." + bcolors.ENDC)
verifier = Verifier(p, q, g, h_list)
result= verifier.verifyProof(proof, ciphertext_list_1, ciphertext_list_2, elgamal.pk)
print(f"Verification result: {result}")
