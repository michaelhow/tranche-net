%namespace SyntaxAnalysis
%visibility internal

%using LexicalAnalysis;
%using AbstractSyntaxTree;
%using AbstractSyntaxTree.InternalTypes;
%using tc;

%start program
%YYSTYPE SemanticValue

/* Terminals */
%token<Token> SETTINGS DEAL COLLATERAL COLLATERALITEM SECURITIES BOND CREDITPAYMENTRULES SIMULATION RULES
%token<Token> RPAREN LBRACE RBRACE RBRACKET PBRACKET DOT DOTDOT COMMA IN TINT TREAL SEMI
%token<Token> TSTRING TBOOL TVOID TCHAR TFILE TSET TLIST FOR IF ELSE CLASS AUTOPROP
%token<Token> NEW RETURN TRUE FALSE LITERAL_INT LITERAL_REAL LITERAL_STRING LITERAL_CHAR IDENTIFIER

/* Precedence rules */
%right ASSIGN
%left OR AND INCREMENT DECREMENT EXP
%left SMALLER GREATER SMEQ GTEQ EQ NEQ
%left PLUS MINUS TIMES DIVIDE MOD
%left UMINUS LPAREN NOT LBRACKET
%nonassoc ELSE

/* Non-terminals, generic */
%type<Prog> program
%type<StatementList> statementList 
%type<Statement> statement 
%type<Expression> expression literal
%type<ExpressionList> onePlusActuals actuals

/* Non-terminals, tranche-specific */
%type<Settings> settingsOpt
%type<Deal> dealOpt
%type<Collateral> collateralSection
%type<CollateralItem> collListOpt
%type<Securities> securitySection
%type<Simulation> simulationSection
%type<Rules> rulesList
%type<Bond> secListOpt
%type<CreditPaymentRules> creditRulesOpt

%%

/* Non-terminal types */
program			: settingsOpt dealOpt collateralSection securitySection	creditRulesOpt simulationSection { $$ = new Prog($1, $2, $3, $4, $5, $6); SyntaxTreeRoot = $$; $$.Location = CurrentLocationSpan; }
				;

settingsOpt		:										{ $$ = new Settings(); $$.Location = CurrentLocationSpan; }
				| SETTINGS LBRACE statementList RBRACE	{ $$ = new Settings($3);  }
				;

dealOpt			:										{ $$ = new Deal(); $$.Location = CurrentLocationSpan; }
				| DEAL LBRACE statementList RBRACE		{ $$ = new Deal($3); $$.Location = CurrentLocationSpan; }
				;

statementList	:										{ $$ = new StatementList(); $$.Location = CurrentLocationSpan; }
				| statement statementList				{ $$ = new StatementList($1, $2); $$.Location = CurrentLocationSpan; }
				;

statement		: SEMI
				| IDENTIFIER SEMI						{ $$ = new StatementVariable(CurrentLocationSpan, $1.Value); $$.Location = CurrentLocationSpan; }
				| IDENTIFIER ASSIGN expression			{ $$ = new StatementVariable(CurrentLocationSpan, $1.Value, $3); $$.Location = CurrentLocationSpan; }
				| LBRACE statementList RBRACE			{ $$ = new Block($2); $$.Location = CurrentLocationSpan; }
				| IF LPAREN expression RPAREN statement			{ $$ = new IfThen($3, $5); $$.Location = CurrentLocationSpan; }
				/*| IF LPAREN expression RPAREN statement ELSE statement  { $$ = new IfThenElse($3, $5, $7); $$.Location = CurrentLocationSpan; }*/
				| expression							{ $$ = new StatementExpression($1); $$.Location = CurrentLocationSpan; }
				;

collateralSection	: COLLATERAL LBRACE collListOpt RBRACE	{ $$ = new Collateral($3); $$.Location = CurrentLocationSpan; }
					;

securitySection : SECURITIES LBRACE secListOpt RBRACE		{ $$ = new Securities($3); $$.Location = CurrentLocationSpan; }
				;

creditRulesOpt	:													{ $$ = new CreditPaymentRules(); $$.Location = CurrentLocationSpan; }
				| CREDITPAYMENTRULES LBRACE statementList RBRACE	{ $$ = new CreditPaymentRules($3); $$.Location = CurrentLocationSpan; }
				;

simulationSection	: SIMULATION LBRACE rulesList RBRACE	{ $$ = new Simulation($3); $$.Location = CurrentLocationSpan; }
					;

collListOpt		:															{ $$ = new CollateralItem(); $$.Location = CurrentLocationSpan; }
				| COLLATERALITEM LBRACE statementList RBRACE collListOpt	{ $$ = new CollateralItem($3, $5); $$.Location = CurrentLocationSpan; }
				;

secListOpt		:												{ $$ = new Bond(); $$.Location = CurrentLocationSpan; }
				| BOND LBRACE statementList RBRACE secListOpt	{ $$ = new Bond($3, $5); $$.Location = CurrentLocationSpan; }
				;

rulesList		: RULES LBRACE statementList RBRACE		{ $$ = new Rules($3); $$.Location = CurrentLocationSpan; }
				;

expression		: IDENTIFIER LPAREN actuals RPAREN		{ $$ = new Invoke($1.Value, $3); $$.Location = CurrentLocationSpan; }
				| literal								{ $$ = $1; $$.Location = CurrentLocationSpan; }
				;

actuals			:					{ $$ = new ExpressionList(); $$.Location = CurrentLocationSpan; }
				| onePlusActuals	{ $$ = $1; $$.Location = CurrentLocationSpan; }
				;

onePlusActuals	: expression		{ $$ = new ExpressionList($1, new ExpressionList()); $$.Location = CurrentLocationSpan; }
				;

literal			: LITERAL_INT		{ $$ = new IntegerLiteral(Int32.Parse($1.Value.ToString().Replace(",",""))); $$.Location = CurrentLocationSpan; } 
				| LITERAL_REAL		{ $$ = new RealLiteral(Double.Parse($1.Value.ToString().Replace(",",""))); $$.Location = CurrentLocationSpan; }
				| LITERAL_STRING	{ $$ = new StringLiteral($1.Value); $$.Location = CurrentLocationSpan; }
				
				/*| LITERAL_CHAR		{ $$ = new ASTChar($1.Value); $$.Location = CurrentLocationSpan; }
				| TRUE				{ $$ = new ASTBoolean(true); $$.Location = CurrentLocationSpan; }
				| FALSE				{ $$ = new ASTBoolean(false); $$.Location = CurrentLocationSpan; }*/
				;

%%

public Prog SyntaxTreeRoot { get; set; }

public Parser(Scanner scan) : base(scan)
{
}