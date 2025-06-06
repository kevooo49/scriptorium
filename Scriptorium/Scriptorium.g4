grammar Scriptorium;

tokens { INDENT, DEDENT }

@lexer::header{
from antlr_denter.DenterHelper import DenterHelper
from Scriptorium.ScriptoriumParser import ScriptoriumParser
}
@lexer::members {
class ScriptoriumDenter(DenterHelper):
    def __init__(self, lexer, nl_token, indent_token, dedent_token, ignore_eof):
        super().__init__(nl_token, indent_token, dedent_token, ignore_eof)
        self.lexer: ScriptoriumLexer = lexer

    def pull_token(self):
        buf = super(ScriptoriumLexer, self.lexer).nextToken()
        # print(buf)
        return buf

denter = None

def nextToken(self):
    if not self.denter:
        self.denter = self.ScriptoriumDenter(self, self.NL, ScriptoriumParser.INDENT, ScriptoriumParser.DEDENT, False)
    buf = self.denter.next_token()
    # print(buf)
    return buf

}


// PARSER

start: action* EOF;

action: variableDeclaration
      | parentVariableDefinition
      | if
      | forLoop
      | whileLoop
      | functionDeclaration
      | functionInvocation DOT NL
      | print
      | errorStatement
      | returnStatement
      | continueStatement
      | breakStatement
      | COMMENT
      ;

expr: boolExpr
    | floatExpr     
    | intExpr       
    | stringExpr       
    | nullExpr      
    | inputExpr
    | functionInvocation
    | varExpr    
    ;

varExpr: PARENT* NAME ;

castedExpr: (INT|FLOAT|STRING|BOOL|functionInvocation|varExpr) AS type=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE)  #CastedValue
          | castedExpr AS type=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE)                                          #CastedAgain
          ;

stringExpr
    : STRING                      #String
    | stringExpr ADD stringExpr   #StringAdd
    | varExpr                     #StringVar
    | STRING_WITH_VAR             #StringWithVar
    | castedExpr                  #StringCast
    | functionInvocation          #StringFunc
    ;

numericExpr: INT                                        #NumericInt
           | FLOAT                                      #NumericFloat
           | LP numericExpr RP                          #NumericBrackets
           | op=(PLUS|MINUS) numericExpr                #NumericPlusMinus
           | numericExpr POW numericExpr                #NumericPow
           | numericExpr op=(MUL|DIV|FDIV) numericExpr  #NumericMulDiv
           | numericExpr op=(ADD|SUB) numericExpr       #NumericAddSub
           | numericExpr MOD numericExpr                #NumericMod
           | varExpr                                    #NumericVar
           | castedExpr                                 #NumericCast
           | functionInvocation                         #NumericFunc
           ;
intExpr: numericExpr #Int ;
floatExpr: numericExpr #Float ;

boolExpr: BOOL                                              #Bool
        | NOT boolExpr                                      #BoolNot
        | LP boolExpr RP                                    #BoolBrackets
        | boolExpr AND boolExpr                             #BoolAnd
        | boolExpr OR boolExpr                              #BoolOr
        | boolExpr op=(EQ|NEQ) boolExpr                     #BoolEqual
        | stringExpr op=(LT|LE|GT|GE|EQ|NEQ) stringExpr     #StringLogic
        | numericExpr op=(LT|LE|GT|GE|EQ|NEQ) numericExpr   #NumericLogic
        | varExpr                                           #BoolVar
        | castedExpr                                        #BoolCast
        | functionInvocation                                #BoolFunc
        ;

nullExpr: NULL #Null ;

errorStatement: ERROR printExpr DOT NL;

funcParam: varType=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE) NAME ;
functionDeclaration: varType=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE|NULL) FUNCTION NAME LP funcParam? (COMMA funcParam)* RP COLON actionBlock ;
functionInvocation: NAME LP expr? (PRINT_SEPARATOR expr)* RP ;

returnStatement: RETURN expr? DOT NL ;

whileLoop: WHILE boolExpr COLON loopBlock ;
forLoop: FOR NAME FROM from=numericExpr TO to=numericExpr COLON loopBlock ;
loopBlock: actionBlock ;

breakStatement: BREAK DOT NL;
continueStatement: CONTINUE DOT NL;

variableDeclaration: varType=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE) variableDefinition
                   | varType=(INT_TYPE|FLOAT_TYPE|STRING_TYPE|BOOL_TYPE) NAME DOT NL;
variableDefinition: NAME IS expr DOT NL;
parentVariableDefinition: PARENT* variableDefinition ;

if: ifBlock ifElseBlock* elseBlock?;

ifBlock: IF boolExpr COLON actionBlock ;
ifElseBlock: ELSE_IF boolExpr COLON actionBlock ;
elseBlock: ELSE COLON actionBlock ;

actionBlock: INDENT action+ DEDENT ;

inputExpr: INPUT printExpr ;

print: PRINT printExpr DOT NL;

printExpr: expr                                 #ExprInPrint
         | printExpr PRINT_SEPARATOR printExpr  #PrintAdd
         ;

any: INT 
   | FLOAT 
   | STRING 
   | BOOL ;

// LEXER

PRINT_SEPARATOR: 'et' ;
ERROR: 'culpa' ;
FUNCTION: 'munus' ;
RETURN: 'reddere' ;
WHILE: 'dum' ;
FOR: 'repetere' ;
FROM: 'ex' ;
TO: 'ad' ;
BREAK: 'exire' ;
CONTINUE: 'perge' ;
ELSE_IF: 'aliter si';
IF: 'si' ;
ELSE: 'aliter' ;
INPUT: 'rogare' ;
PRINT: 'scribere' ;

PLUS: 'positivum' ;
MINUS: 'negans' ;

INT: (PLUS|MINUS)? [0-9]+ ;
FLOAT: (PLUS|MINUS)? [0-9]+ ',' [0-9]+ ;
fragment ESC: '\\' ["\\] ;
STRING_WITH_VAR: '"' (ESC | ~["\\\n] | '{' NAME '}')* '"' ;
STRING: '"' (ESC | ~["\\\n])* '"' ;
BOOL: ('verum'|'falsum') ;

INT_TYPE: 'numerus' ;
FLOAT_TYPE: 'fractio' ;
BOOL_TYPE: 'veritas' ;
STRING_TYPE: 'sententia' ;

PARENT: 'parentes' ;

AS: 'ut' ;

NULL: 'nihil' ;

IS: 'esto' ; // =

ADD: 'adde'; // "+"
SUB: 'minue'; // "-"
MUL: 'multiplica'; // "*"
DIV: 'divide'; // "/"
POW: 'potentia'; // "^"
MOD: 'residuum'; // "%"
FDIV: 'totum'; // "//"

AND: 'etiam' ; // "&&"
OR: 'aut' ; // "||"
NOT: 'non' ; // "!"

LT: 'minor quam' ; // “<”
LE: 'minor aequalis' ; // “<=”
GT: 'maior quam' ; // “>”
GE: 'maior aequalis' ; // “>=”

EQ: 'aequalis' ; // "=="
NEQ: 'inaequale' ; // "!="

DOT: '.' ;
COMMA: ',' ;
COLON: ':' ;
LP: '(' ;
RP: ')' ;

NAME: [a-z_]+[a-zA-Z0-9_]* ;

COMMENT: '\t'* '//' .*? NL -> channel(HIDDEN);

NL: ('\r'? '\n') '\t'*;
WS: [ ]+ -> skip;
// WS: [ ]+ -> channel(HIDDEN) ;
// NL: ('\r'? '\n');
