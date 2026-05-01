#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include "main.h" // data structures and maps

#define MAX_LINES 256

int _getRSEL(const char* reg_name) {
    struct RSEL rsel[] = {
        {"R1", 0},
        {"R2", 1},
        {"R3", 2},
        {"R4", 3}
    };
    int size = sizeof(rsel) / sizeof(rsel[0]);
    for(int i = 0; i < size; ++i) {
        if(strcmp(rsel[i].reg, reg_name) == 0) {
            return rsel[i].binary;
        }
    }
    return -1;
}
Label labels[256];

int label_count = 0;

void save_label(const char* buffer, int curr_add) {
    strcpy(labels[label_count].name, buffer);
    labels[label_count].address = curr_add;
    label_count++;
}


int label_interrupt(const char* label_name) {
    for(int i = 0; i < label_count; ++i) {
        if(strcmp(label_name, labels[i].name) == 0) {
            return labels[i].address;
        }
    }
    return -1;
}


int _getSecondDesignReg(const char* reg_name) {
    struct second_design_reg list[] = {
        {"PC", 0},
        {"AR", 2},
        {"SP", 3},
        {"R1", 4},
        {"R2", 5},
        {"R3", 6},
        {"R4", 7}
    };
    int size = sizeof(list) / sizeof(list[0]);
    for(int i = 0; i < size; ++i) {
        if(strcmp(list[i].reg, reg_name) == 0) {
            return list[i].binary;
        }
    }
    return -1;
}

int _getOpcodeValue(const char* opcode) {
    struct OpcodeEntry instructions[] = {
        {"BRA", 0x00 },
        {"BNE", 0x01},
        {"BEQ", 0x02},
        {"BLT", 0x03},
        {"BGT", 0x04},
        {"BLE", 0x05},
        {"BGE", 0x06},
        {"INC", 0x07},
        {"DEC", 0x08},
        {"LSL", 0x09},
        {"LSR", 0x0A},
        {"ASR", 0x0B},
        {"CSL", 0x0C},
        {"CSR", 0x0D},
        {"NOT", 0x0E},
        {"AND", 0x0F},
        {"ORR", 0x10},
        {"XOR", 0x11},
        {"NAND", 0x12},
        {"ADD", 0x13},
        {"ADC", 0x14},
        {"SUB", 0x15},
        {"MOV", 0x16},
        {"IMM", 0x17},
        {"POP", 0x18},
        {"PSH", 0x19},
        {"CALL", 0x1A},
        {"RET", 0x1B},
        {"LDR", 0x1C},
        {"STR", 0x1D},
        {"LDA", 0x1E},
        {"STA", 0x1F},
        {"LDT", 0x20},
        {"STT", 0x21},
    };
    int size = sizeof(instructions) / sizeof(instructions[0]);
    for(int i = 0; i < size; ++i) {
        if(strcmp(instructions[i].name, opcode) == 0) {
            return instructions[i].hex;
        }
    }
    return -1;
}
char* trim(char* str) {
    while (*str == ' ' || *str == '\t')
        str++;

    char* end = str + strlen(str) - 1;
    while (end > str && (*end == ' ' || *end == '\t')) {
        *end = '\0';
        end--;
    }

    return str;
}






int exec_instruction(const char* line, int current_add, uint16_t* out) {

    *out = 0;

    char buffer[256];
    strcpy(buffer, line);


    char *colon = strchr(buffer, ':');
    char *inst_start = buffer;

    if (colon != NULL) {
        *colon = '\0';
        inst_start = colon + 1;
    }

    const char* Opcode = strtok(inst_start, " ");


    if(Opcode == NULL) {
        return 1;
    }

    int index_opcode = _getOpcodeValue(Opcode);
    if(index_opcode == -1) {
        fprintf(stderr, "Error -- at line %d: no such opcode exists\n", current_add + 1);
        return -1;
    }

    Instruction inst;
    memset(&inst, 0, sizeof(inst));

    if(index_opcode <= 6) {
        inst.type = TYPE_FIRST;
        inst.data.A.opcode_index = index_opcode;
        inst.data.A.reg = 0;
        inst.data.A.address = 0;

        char *addr_str = strtok(NULL, " ");
        if(addr_str == NULL) {
            fprintf(stderr, "Error -- at line %d: wrong address\n", current_add + 1);
        } else {
            int is_label = label_interrupt(addr_str);
            if(is_label != -1) {
                inst.data.A.address = is_label;
            } else {
                inst.data.A.address = (int)strtol(addr_str, NULL, 0);
            }
        }
    } else if(index_opcode == 23) { // IMM
        inst.type = TYPE_FIRST;
        inst.data.A.opcode_index = index_opcode;
        char *rsel_str = strtok(NULL, ",");
        char *addr_str = strtok(NULL, " ");
        if (addr_str != NULL) {
            inst.data.A.address = (int)strtol(addr_str, NULL, 0);
        }
        inst.data.A.reg = _getRSEL(rsel_str);

        if(inst.data.A.reg == -1) {
            fprintf(stderr, "Error -- at line %d: missing or invalid register(s)\n", current_add + 1);
            return -1;
        }
    } else if((index_opcode >= 7 && index_opcode <= 14) || index_opcode == 22) {
        inst.type = TYPE_SECOND;
        inst.data.B.opcode_index = index_opcode;

        char* dstreg_str = strtok(NULL, ",");
        if (dstreg_str) dstreg_str = trim(dstreg_str);

        char* sreg1_str = strtok(NULL, " ");
        if (sreg1_str) sreg1_str = trim(sreg1_str);

        inst.data.B.DSTREG = dstreg_str ? _getSecondDesignReg(dstreg_str) : -1;
        inst.data.B.SREG1  = sreg1_str  ? _getSecondDesignReg(sreg1_str)  : -1;
        inst.data.B.SREG2  = 0;

        if(inst.data.B.DSTREG == -1 || inst.data.B.SREG1 == -1) {
            fprintf(stderr, "Error -- at line %d: missing or invalid register(s)\n", current_add + 1);
            return -1;
        }
    } else if(index_opcode >= 15 && index_opcode <= 21) {
        inst.type = TYPE_SECOND;
        inst.data.B.opcode_index = index_opcode;

        char* dstreg_str = strtok(NULL, ",");
        if (dstreg_str) dstreg_str = trim(dstreg_str);

        char* sreg1_str = strtok(NULL, ",");
        if (sreg1_str) sreg1_str = trim(sreg1_str);

        char* sreg2_str = strtok(NULL, "");
        if (sreg2_str) sreg2_str = trim(sreg2_str);

        inst.data.B.DSTREG = dstreg_str ? _getSecondDesignReg(dstreg_str) : -1;
        inst.data.B.SREG1  = sreg1_str  ? _getSecondDesignReg(sreg1_str)  : -1;
        inst.data.B.SREG2  = sreg2_str  ? _getSecondDesignReg(sreg2_str)  : -1;

        if(inst.data.B.DSTREG == -1 || inst.data.B.SREG1 == -1 || inst.data.B.SREG2 == -1) {
            fprintf(stderr, "Error -- at line %d: missing or invalid register(s)\n", current_add + 1);
            return -1;
        }
    } else {
        fprintf(stderr, "Error -- at line %d: unhandled opcode %d\n", current_add + 1, index_opcode);
        return -1;
    }

    if(inst.type == TYPE_FIRST) {
        *out |= (inst.data.A.opcode_index << 10);
        *out |= (inst.data.A.reg << 8);
        *out |= (inst.data.A.address << 0);
    } else {
        *out |= (inst.data.B.opcode_index << 10);
        *out |= (inst.data.B.DSTREG << 7);
        *out |= (inst.data.B.SREG1 << 4);
        *out |= (inst.data.B.SREG2 << 1);
    }
    return 0;
}




void read_assembly(const char* filename) {
    FILE* file = fopen(filename, "r");
    if(file == NULL) {
        perror("Error while openning the file");
        return;
    }


    label_count = 0;
    char line_buffer[256];
    int current_add = 0;

    while(fgets(line_buffer, sizeof(line_buffer), file)) {
        line_buffer[strcspn(line_buffer, "\r\n")] = 0;

        if (line_buffer[0] == '\0' || line_buffer[0] == ' ') continue;

        char *comment = strchr(line_buffer, '#');
        if (comment) *comment = '\0';


        char* trimmed = trim(line_buffer);
        if (trimmed[0] == '\0') continue;

        char temp[256];
        strcpy(temp, trimmed);
        char *colon = strchr(temp, ':');

        if (colon != NULL) {
            *colon = '\0';
            save_label(trim(temp), current_add);

            char *rest = trim(colon + 1);
            if (rest[0] == '\0') {
                continue;
            }
        }
        current_add++;
    }

    printf("[Pass 1] Found %d label(s)\n", label_count);
    for(int i = 0; i < label_count; i++) {
        printf("  %s -> 0x%02X\n", labels[i].name, labels[i].address);
    }


    rewind(file);
    uint16_t all_instructions[MAX_LINES] = {0};
    current_add = 0;
    int errors = 0;

    while(fgets(line_buffer, sizeof(line_buffer), file)) {
        line_buffer[strcspn(line_buffer, "\r\n")] = 0;

        if (line_buffer[0] == '\0' || line_buffer[0] == ' ') continue;

        char *comment = strchr(line_buffer, '#');
        if (comment) *comment = '\0';

        char* trimmed2 = trim(line_buffer);
        if (trimmed2[0] == '\0') continue;

        uint16_t encoded = 0;
        int result = exec_instruction(trimmed2, current_add, &encoded);

        if(result == -1) {
            errors++;
            current_add++;
        } else if(result == 1) {} else {
            all_instructions[current_add] = encoded;
            printf("  [0x%02X] 0x%04X\n", current_add, encoded);
            current_add++;
        }
    }
    fclose(file);

    if(errors > 0) {
        fprintf(stderr, "Assembly FAILED: %d error(s).\n", errors);
        return;
    }

    uint8_t rom_data[256] = {0};
    for(int i = 0; i < current_add; i++) {
        rom_data[i * 2]     = all_instructions[i] & 0xFF;
        rom_data[i * 2 + 1] = (all_instructions[i] >> 8) & 0xFF;
    }

    FILE* out = fopen("ROM.mem", "w");
    if (out == NULL) {
        perror("Error opening ROM.mem for writing");
        return;
    }
    for (int i = 0; i < 256; i++) {
        fprintf(out, "%02X\n", rom_data[i]);
    }
    fclose(out);
    printf("\nROM.mem written successfully (%d instructions)\n", current_add);
}

int main(int argc, char *argv[]){

    if(argc < 2) {
        printf("Usage: ./assembler <file.asm>\n");
        return 1;
    }

    char* filename = argv[1];

    FILE *fp = fopen(filename, "r");

    if (fp == NULL) {
        perror("Error -- file cannot be openned");
        return 1;
    }
    read_assembly(filename);

    fclose(fp);

    return 0;
}





