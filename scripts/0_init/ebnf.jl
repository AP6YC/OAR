using
    Revise,
    OAR

N = [
    "SL", "SW", "PL", "PW"
]

T = [
    "SL1", "SL2", "SL3", "SL4", "SL5", "SL6", "SL7", "SL8", "SL9", "SL10",
    "SW1", "SW2", "SW3", "SW4", "SW5", "SW6", "SW7", "SW8", "SW9", "SW10",
    "PL1", "PL2", "PL3", "PL4", "PL5", "PL6", "PL7", "PL8", "PL9", "PL10",
    "PW1", "PW2", "PW3", "PW4", "PW5", "PW6", "PW7", "PW8", "PW9", "PW10",
]


# IRIS BNF grammar, Meuth dissertation p.48, Table 4.6
# N = {SL, SW, PL, PW}
# T = {SL1, SL2, SL3, SL4, SL5, SL6, SL7, SL8, SL9, SL10,
# SW1, SW2, SW3, SW4, SW5, SW6, SW7, SW8, SW9, SW10,
# PL1, PL2, PL3, PL4, PL5, PL6, PL7, PL8, PL9, PL10,
# PW1, PW2, PW3, PW4, PW5, PW6, PW7, PW8, PW9, PW10,}
# S = <SL> <SW> <PL> <PW>
# P can be represented as:
# 1. <SL> ::=
# {SL1 | SL2 | SL3 | SL4 | SL5 |
# SL6 | SL7 | SL8 | SL9 | SL10}
# 2. <SW> ::=
# {SW1 | SW2 | SW3 | SW4 | SW5 |
# SW6 | SW7 | SW8 | SW9 | SW10}
# 3. <PL> ::=
# {PL1 | PL2 | PL3 | PL4 | PL5 |
# PL6 | PL7 | PL8 | PL9 | PL10}
# 4. <PW> ::=
# {PW1 | PW2 | PW3 | PW4 | PW5 |
# PW6 | PW7 | PW8 | PW9 | PW10}