/*
 * rm-makestuff.c
 *   Depending on options, removes non-deterministic data on files
 */


#include <string.h>
#include <stdio.h>


int main(int argc, char** argv) {
    /* variable declarations */
    int count = 0;
    char current_char;
    FILE* fptr;
    long file_size = 0;
    char* buffer1;  /* first buffer will contain special chars */
    char* buffer2;  /* second buffer will not */
    char* special_char = (char *)-56;
    int i, j, idx;
    int badsymbols = 0;
    char* key1 = "# environment";
    char* key2 = "inode";
    char* key3 = "device";
    char* key4 = "variable";
    char* key5 = "bucket";
    char* key6 = "child";
    char* arg1 = "-p";
    char* arg2 = "-d";
    char* arg3 = "-a";
    int is_key2, is_key3, need_key2, need_key3;
    int is_key4, is_key5, need_key4, need_key5;
    int temp_i;

    /* check for bad input */
    if (argc != 3) {
        fprintf(stderr, "Usage: rm-env [-p|-d|-a] <file_name>\n");
        exit(1);
    }
    /* open file */
    if ((fptr = fopen(argv[2], "r+")) == NULL) {
        fprintf(stderr, "Error: bad file name\n");
        exit(1);
    }

    /* count number of bytes in file & allocate buffer1 */
    fseek(fptr, 0, SEEK_SET);
    while ((current_char = fgetc(fptr)) != EOF) {
       file_size++;
    }
    buffer1 = (char *) malloc(sizeof(char) * (file_size + 1));

    /* read file into buffer1 */
    rewind(fptr);
    i = 0;
    buffer1 = (char *) malloc(sizeof(char) * (file_size + 1));
    while ((buffer1[i] = fgetc(fptr)) != EOF) {
        i++;  /* spank it */
    }

    if ((strcmp(argv[1], arg1) == 0) || (strcmp(argv[1], arg3) == 0)) {
        /* write specials to replace "# environment" */
        i = count = 0;
        rewind(fptr);
        while (buffer1[i] != EOF) {
            if (buffer1[i] == '\n') {
                /* at newline, reset stuff */
                count = 0;
            }
            else {
                if (buffer1[i] == key1[count]) {
                    /* continue... */
                    count++;
                    if (count == 13) {
                        /* done with "# environment" */
                        temp_i = i;
                        while (buffer1[temp_i] != '\n')
                            temp_i--;
                        /* remove # environment */
                        do {
                            buffer1[temp_i++] = special_char;
                            badsymbols++;
                        } while (buffer1[temp_i] != '\n');
                        /* remove the next line */
                        do {
                            buffer1[temp_i++] = special_char;
                            badsymbols++;
                        } while (buffer1[temp_i] != '\n');
                        i = temp_i;
                        count = 0;
                    }
                }
                else {
                    /* not child... */
                    count = 0;
                }
            }
            i++;
        }

        /* remove lines with both device and inode */
        i = 0;
        is_key2 = 0;
        is_key3 = 0;
        need_key2 = 1;
        need_key3 = 1;
        while (buffer1[i] != EOF) {
            if (buffer1[i] == '\n') {
                /* at newline, reset stuff */
                count = 0;
                need_key2 = 1;
                need_key3 = 1;
                is_key2 = 0;
                is_key3 = 0;
            }
            else if (is_key2 == 1) {
                /* going for key2, "inode" */
                if (buffer1[i] == key2[count]) {
                    /* continue... */
                    count++;
                    if (count == 5) {
                        /* done with inode */
                        is_key2 = 0;
                        need_key2 = 0;
                        count = 0;
                        if (need_key3 == 0) {
                            /* got device & inode in one line */
                            temp_i = i;
                            while (buffer1[temp_i] != '\n')
                                temp_i--;
                            do {
                                buffer1[temp_i++] = special_char;
                                badsymbols++;
                            } while (buffer1[temp_i] != '\n');
                            i = temp_i;
                            count = 0;
                            need_key2 = 1;
                            need_key3 = 1;
                            is_key2 = 0;
                            is_key3 = 0;
                        }
                    }
                }
                else {
                    /* not inode... */
                    is_key2 = 0;
                    count = 0;
                }
            }
            else if (is_key3 == 1) {
                /* going for key3, "device" */
                if (buffer1[i] == key3[count]) {
                    /* continue... */
                    count++;
                    if (count == 6) {
                        /* done with device */
                        is_key3 = 0;
                        need_key3 = 0;
                        count = 0;
                        if (need_key2 == 0) {
                            /* get device & inode */
                            temp_i = i;
                            while (buffer1[temp_i] != '\n')
                                temp_i--;
                            do {
                                buffer1[temp_i++] = special_char;
                                badsymbols++;
                            } while (buffer1[temp_i] != '\n');
                            i = temp_i;
                            count = 0;
                            need_key2 = 1;
                            need_key3 = 1;
                            is_key2 = 0;
                            is_key3 = 0;
                        }
                    }
                }
                else {
                    /* not device... */
                    is_key3 = 0;
                    count = 0;
                }
            }
            else {
                /* haven't started key2 or key3 yet */
                if (buffer1[i] == key2[0]) {
                    /* start key2 */
                    is_key2 = 1;
                    count++;
                }
                else if (buffer1[i] == key3[0]) {
                    /* start key3 */
                    is_key3 = 1;
                    count++;
                }
            }
            i++;
        }

        /* remove lines with both "variable" and "bucket" */
        i = 0;
        is_key4 = 0;
        is_key5 = 0;
        need_key4 = 1;
        need_key5 = 1;
        while (buffer1[i] != EOF) {
            if (buffer1[i] == '\n') {
                /* at newline, reset stuff */
                count = 0;
                need_key4 = 1;
                need_key5 = 1;
                is_key4 = 0;
                is_key5 = 0;
            }
            else if (is_key4 == 1) {
                /* going for key4, "variable" */
                if (buffer1[i] == key4[count]) {
                    /* continue... */
                    count++;
                    if (count == 8) {
                        /* done with variables */
                        is_key4 = 0;
                        need_key4 = 0;
                        count = 0;
                        if (need_key5 == 0) {
                            /* got variables & bucket in one line */
                            temp_i = i;
                            while (buffer1[temp_i] != '\n')
                                temp_i--;
                            do {
                                buffer1[temp_i++] = special_char;
                                badsymbols++;
                            } while (buffer1[temp_i] != '\n');
                            i = temp_i;
                            count = 0;
                            need_key4 = 1;
                            need_key5 = 1;
                            is_key4 = 0;
                            is_key5 = 0;
                        }
                    }
                }
                else {
                    /* not variable... */
                    is_key4 = 0;
                    count = 0;
                }
            }
            else if (is_key5 == 1) {
                /* going for key5, "bucket" */
                if (buffer1[i] == key5[count]) {
                    /* continue... */
                    count++;
                    if (count == 6) {
                        /* done with bucket */
                        is_key5 = 0;
                        need_key5 = 0;
                        count = 0;
                        if (need_key4 == 0) {
                            /* get variable & bucket */
                            temp_i = i;
                            while (buffer1[temp_i] != '\n')
                                temp_i--;
                            do {
                                buffer1[temp_i++] = special_char;
                                badsymbols++;
                            } while (buffer1[temp_i] != '\n');
                            i = temp_i;
                            count = 0;
                            need_key4 = 1;
                            need_key5 = 1;
                            is_key4 = 0;
                            is_key5 = 0;
                        }
                    }
                }
                else {
                    /* not bucket... */
                    is_key5 = 0;
                    count = 0;
                }
            }
            else {
                /* haven't started key4 or key5 yet */
                if (buffer1[i] == key4[0]) {
                    /* start key4 */
                    is_key4 = 1;
                    count++;
                }
                else if (buffer1[i] == key5[0]) {
                   /* start key5 */
                   is_key5 = 1;
                   count++;
                }
            }
            i++;
        }
    }

    if ((strcmp(argv[1], arg2) == 0) || (strcmp(argv[1], arg3) == 0)) {
        /* remove all lines with child in them by writing specials */
        i = 0;
        count = 0;
        rewind(fptr);
        while (buffer1[i] != EOF) {
	        if (buffer1[i] == '\n') {
	            /* at newline, reset stuff */
                count = 0;
	        }
            else {
                if (buffer1[i] == key6[count]) {
                    /* continue... */
                    count++;
                    if (count == 5) {
                        /* done with child */
                        temp_i = i;
                        while (buffer1[temp_i] != '\n')
                            temp_i--;
                        do {
                            buffer1[temp_i++] = special_char;
                            badsymbols++;
                        } while (buffer1[temp_i] != '\n');
                        i = temp_i;
                        count = 0;
                    }
                }
                else {
                    /* not child... */
                    count = 0;
                }
            }
	        i++;
        }
    }

/*
    printf("%d\n", badsymbols);
    printf("%d     %d\n", file_size, i);
    getchar();
*/
    /* copy contents of buffer1 to buffer2 without special chars */
    rewind(fptr);  /* go back to beginning of file */
    buffer2 = (char *) malloc(sizeof(char) * (file_size + 1 - badsymbols));
    i = j = 0;
    while ((current_char = fgetc(fptr)) != EOF) {
        /* printf("%c      %d   %c\n", current_char, i, buffer1[i]); */
        if (buffer1[i] != special_char) {
            buffer2[j++] = buffer1[i];
	        /* printf("here.....<><><> %c\n", buffer2[j - 1]); */
        }
        i++;
    }
    buffer2[j] = '\n';
/*
    printf("%c\n", buffer2[j]);
    printf("%i     %i\n", i, j);
    printf("%d\n", file_size + 1 - badsymbols);
    getchar();
*/
    /* delete file and write contents of buffer to new file */
    fclose(fptr);
    if ((fptr = fopen(argv[2], "w")) == NULL) {
        fprintf(stderr, "Error recreating file upon rewrite\n");
        exit(1);
    }
    i = 0;
    while (buffer2[i] != '\0') {
        putc(buffer2[i++], fptr);
        /* printf("%c            %d\n", buffer2[i - 1], i - 1); */
    }

    fclose(fptr);
    return 0;
}  /* end of main */
