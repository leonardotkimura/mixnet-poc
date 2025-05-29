from hashlib import sha512
from Crypto.Util.number import bytes_to_long

class Hash:
    @staticmethod
    def text_to_integer(text, modulo):
        hash_value = sha512(text.encode()).digest()
        h = bytes_to_long(hash_value)
        group = IntegerModRing(modulo)
        return group(h)


