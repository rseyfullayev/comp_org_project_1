struct Instruction {
    const char* name;
    int hex;
};

struct RSEL {
    const char* reg;
    int binary;
};

struct second_design_reg {
    const char* reg;
    int binary;
};

typedef struct {
    int opcode_index;
    int reg;
    int address;
} first_design; // INSTRUCTION REGSEL ADDRESS

typedef struct {
    int opcode_index;
    int DSTREG;
    int SREG1;
    int SREG2;
} second_design; // INSTRUCTION DSTREG, SREG1, SREG2