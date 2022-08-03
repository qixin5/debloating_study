%%

xyz"++"		printf("Match character: %s\n", yytext);
[xyz]		printf("Character class[x, y or z]: %s\n", yytext);
[abj-oZ]	printf("Character class with range: %s\n", yytext);
[^A-Z\n]	printf("Negated character class with range: %s\n", yytext);
"[XYZ]\"foo"	printf("The literal string: %s\n", yytext);
.		printf("Any character except newline: %s\n", yytext);
