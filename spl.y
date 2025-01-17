 /* $Id: bison_spl_y_top.y,v 1.2 2024/10/09 18:18:55 leavens Exp $ */

%code top {
#include <stdio.h>
}

%code requires {

 /* Including "ast.h" must be at the top, to define the AST type */
#include "ast.h"
#include "machine_types.h"
#include "parser_types.h"
#include "lexer.h"

    /* Report an error to the user on stderr */
extern void yyerror(const char *filename, const char *msg);

}    /* end of %code requires */
%union {
    int number;               // For integer values
    char *ident;              // For identifiers
    char token;               // For single-character tokens
    block_stmt_t block;       // For block statements
    stmts_t statements;       // For lists of statements
    stmt_t statement;         // For a single statement
    expr_t expression;        // For expressions
    term_t term;             // For terms
    factor_t factor;          // For factors
    condition_t condition;     // For conditions (if, while, etc.)
    db_condition_t dbCondition; // For database conditions
    rel_op_t relOp;           // For relational operators
    const_decls_t constDecls; // For constant declarations
    var_decls_t varDecls;     // For variable declarations
    proc_decls_t procDecls;   // For procedure declarations
}

%verbose
%define parse.lac full
%define parse.error detailed

 /* the following passes file_name to yyerror,
    and declares it as an formal parameter of yyparse. */
%parse-param { char const *file_name }

%token <ident> identsym
%token <number> numbersym
%token <token> plussym    "+"
%token <token> minussym   "-"
%token <token> multsym    "*"
%token <token> divsym     "/"
%token <token> periodsym  "."
%token <token> semisym    ";"
%token <token> eqsym      "="
%token <token> commasym   ","
%token <token> becomessym ":="
%token <token> lparensym  "("
%token <token> rparensym  ")"

%token <token> constsym   "const"
%token <token> varsym     "var"
%token <token> procsym    "proc"
%token <token> callsym    "call"
%token <token> beginsym   "begin"
%token <token> endsym     "end"
%token <token> ifsym      "if"
%token <token> thensym    "then"
%token <token> elsesym    "else"
%token <token> whilesym   "while"
%token <token> dosym      "do"
%token <token> readsym    "read"
%token <token> printsym   "print"
%token <token> divisiblesym "divisible"
%token <token> bysym      "by"

%token <token> eqeqsym    "=="
%token <token> neqsym     "!="
%token <token> ltsym      "<"
%token <token> leqsym     "<="
%token <token> gtsym      ">"
%token <token> geqsym     ">="

%type <block> program

%type <block> block

%type <const_decls> constDecls
%type <const_decl> constDecl
%type <const_def_list> constDefList
%type <const_def> constDef

%type <var_decls> varDecls
%type <var_decl> varDecl
%type <ident_list> identList

%type <proc_decls> procDecls
%type <proc_decl> procDecl


%type <stmts> stmts
%type <empty> empty
%type <stmt_list> stmtList
%type <stmt> stmt
%type <assign_stmt> assignStmt
%type <call_stmt> callStmt
%type <if_stmt> ifStmt
%type <while_stmt> whileStmt
%type <read_stmt> readStmt
%type <print_stmt> printStmt
%type <block_stmt> blockStmt

%type <condition> condition
%type <db_condition> dbCondition
%type <rel_op_condition> relOpCondition
%type <token> relOp

%type <expr> expr
%type <expr> term
%type <expr> factor

%start program

%code {
 /* extern declarations provided by the lexer */
extern int yylex(void);

 /* The AST for the program, set by the semantic action 
    for the nonterminal program. */
block_t progast; 

 /* Set the program's ast to be t */
extern void setProgAST(block_t t);
}

%%
 /* Write your grammar rules below and before the next %% */

// Grammar Rules
program:
    block_stmt semisym   // A program consists of a block statement followed by a semicolon
    ;

block_stmt:
    lparensym statements rparensym  // A block statement enclosed in parentheses
    ;

statements:
    statement  // A single statement
    | statements statement  // Multiple statements
    ;

statement:
    printStmt  // A print statement
    | assignmentStmt  // An assignment statement
    ;

printStmt:
    plussym lparensym expression rparensym  // Print statement syntax
    ;

assignmentStmt:
    identsym becomessym expression  // Assignment statement syntax
    ;

expression:
    term  // An expression can be a term
    | expression plussym term  // Or an expression followed by a plus and another term
    | expression minussym term  // Or an expression followed by a minus and another term
    ;

term:
    factor  // A term can be a factor
    | term multsym factor  // Or a term followed by a multiplication and another factor
    | term divsym factor  // Or a term followed by a division and another factor
    ;

factor:
    numbersym  // A factor can be a number
    | identsym  // Or an identifier
    | lparensym expression rparensym  // Or an expression enclosed in parentheses
    ;




%%

// Set the program's ast to be ast
void setProgAST(block_t ast) { progast = ast; }

