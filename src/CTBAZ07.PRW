#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

#DEFINE CTITULO "Regras de Contabilização."
#DEFINE NCLIENTE 1
#DEFINE NFORNECEDOR 2
#DEFINE NPRODUTO 3
#DEFINE NNATUREZA 4
#DEFINE NBANCO 5
#DEFINE NFOLHAPGTO 6
#DEFINE NENTIDADE 7
#DEFINE NATIVO 8

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Regras de Contabilização.                                     |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ07()

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local aTFolder
	Local cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
		
	Private oTFolder
	Private oDlgPrinc
	Private cCadastro := CTITULO
	
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "3"    
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))	
	
	oDlgPrinc := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], "Regras de Contabilização.", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 
		
	// Cria a Folder
  	aTFolder := { 'Cliente', 'Fornecedor', 'Produto', 'Natureza Financeira', 'Banco', 'Folha de Pagamento', 'Entidade Padrão', 'Ativo Fixo' }
  	oTFolder := TFolder():New( 0, 0, aTFolder,,oDlgPrinc,,,,.T.,, 0, 0 )		
  	
  	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT 
  	
  	AbaCliente()
  	AbaFornecedor()
  	AbaProduto()  	
  	AbaNatureza()
  	AbaBanco()
  	AbaEntidade()
  	AbaFolha()
  	AbaAtivo()  	
  	 	
	oDlgPrinc:Activate( , , , , , , EnchoiceBar( oDlgPrinc, {|| }, { || oDlgPrinc:End() }, , {}, , , , , .F., .F. ) ) //ativa a janela criando uma enchoicebar
		
Return NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaCliente()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NCLIENTE], .F., .T. )
		
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription(  'Cadastro de Clientes.' )
	oBrowseLeft:SetAlias( 'SA1' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'A1_COD','A1_LOJA','A1_NOME','A1_CONTA'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaFornecedor()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NFORNECEDOR], .F., .T. )
		
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Fornecedores.' )
	oBrowseLeft:SetAlias( 'SA2' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'A2_COD','A2_LOJA','A2_NOME','A2_CONTA'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaProduto()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NPRODUTO], .F., .T. )
	
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Produtos.' )
	oBrowseLeft:SetAlias( 'SB1' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'B1_COD','B1_DESC','B1_CONTA','B1_CC','B1_ITEMCC','B1_CLVL'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaNatureza()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NNATUREZA], .F., .T. )
			
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Naturezas.' )
	oBrowseLeft:SetAlias( 'SED' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'ED_CODIGO','ED_DESCRIC','ED_CONTA'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaBanco()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NBANCO], .F., .T. )
		
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Bancos.' )
	oBrowseLeft:SetAlias( 'SA6' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'A6_COD','A6_AGENCIA','A6_NUMCON','A6_NOME','A6_CONTA'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaEntidade()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight
	Local cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
	Local cCtbaCpo := ""  	
	
	cCtbaTab := AllTrim(cCtbaTab) + "2"    
	cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))		
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NENTIDADE], .F., .T. )
				
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Entidades.' )
	oBrowseLeft:SetAlias( cCtbaTab )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ05' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({cCtbaCpo + '_CODIGO', cCtbaCpo + '_RETORN', cCtbaCpo + '_CONTA', cCtbaCpo + '_DESCON'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Contas contábeis da folha de pagamento.                       |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaFolha()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft, oBrowseRight, oRelac
	Local cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
	Local cCtbaCpo := ""  	
	
	cCtbaTab := AllTrim(cCtbaTab) + "3"    
	cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))		
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NFOLHAPGTO], .F., .T. )

	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'PAINEL', 95, .F. )
	
	//
	// Cria uma "linha" com 50% da tela
	//
	oFWLayer:AddCollumn( 'LEFT',   49, .T., 'PAINEL' )
	oFWLayer:AddCollumn( 'CENTER', 02, .T., 'PAINEL' )
	oFWLayer:AddCollumn( 'RIGHT',  49, .T., 'PAINEL' )
	
	//
	// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	//
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'PAINEL' ) // Pego o objeto do pedaço esquerdo
	oPanelRight := oFWLayer:GetColPanel( 'RIGHT', 'PAINEL' ) // Pego o objeto do pedaço direito
	
	//
	// Lado Esquerdo Verbas
	//
	oBrowseLeft:= FWmBrowse():New()
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( "Verbas" )
	oBrowseLeft:SetAlias( 'SRV' )
	oBrowseLeft:SetMenuDef( '' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	oBrowseLeft:Activate()
	
	//
	// Lado Direito Centro de Custo
	//
	oBrowseRight:= FWMBrowse():New()
	oBrowseRight:SetOwner( oPanelRight )
	oBrowseRight:SetAlias( cCtbaTab )
	oBrowseRight:SetDescription( 'Centro de Custo' )
	oBrowseRight:SetMenuDef( 'CTBAZ06' )
	oBrowseRight:DisableDetails()
	oBrowseRight:SetProfileID( '2' )
	oBrowseRight:ForceQuitButton()
	oBrowseRight:Activate()
	
	//
	// Relacionamento entre os Paineis
	//
	oRelac := FWBrwRelation():New()
	oRelac:AddRelation( oBrowseLeft , oBrowseRight , { { cCtbaCpo + '_FILIAL', 'xFilial("' + cCtbaTab + '")' }, { cCtbaCpo + '_VERBA' , 'RV_COD' } } )
	oRelac:Activate()

Return Nil

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ07   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria pasta padrão                                             |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function AbaAtivo()

  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft, oBrowseRight
  		
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oTFolder:aDialogs[NATIVO], .F., .T. )
				
	//
	// Define Painel Superior
	//
	oFWLayer:AddLine( 'UP', 95, .F. )
	
	oFWLayer:AddCollumn( 'LEFT', 100, .T., 'UP' )
	
	oPanelLeft  := oFWLayer:GetColPanel( 'LEFT' , 'UP' ) // Pego o objeto do pedaço esquerdo
	
 	oBrowseLeft := FWmBrowse():New()
 	
	oBrowseLeft:SetOwner( oPanelLeft )
	oBrowseLeft:SetDescription( 'Cadastro de Ativos.' )
	oBrowseLeft:SetAlias( 'SN1' )
	oBrowseLeft:SetOnlyFields( { '' } ) 		
	oBrowseLeft:SetMenuDef( 'CTBAZ07' )
	oBrowseLeft:DisableDetails()
	oBrowseLeft:SetProfileID( '1' )
	oBrowseLeft:ForceQuitButton()
	
	aColunas := getProField({'N1_CBASE','N1_ITEM','N1_DESCRIC'})
			
	oBrowseLeft:SetFields(aColunas)
	
	oBrowseLeft:Activate()
	
Return Nil


/*---------+----------+-------+-----------------------+------+------------+
|Função    |MenuDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Menu da Rotina                                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ07" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ07" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ07" OPERATION 8                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local oStruct := Nil
    Local oStrDet := Nil
    Local oModel  := Nil
    Local aChave  := ''
    Local cCampos := ''
    Local aRelac  := {}
	Local cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
	Local cCtbaCpo := ""  	
	
	cCtbaTab := AllTrim(cCtbaTab) + "3"    
	cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))			
    
    Do Case
    
    	Case oTFolder:nOption == NCLIENTE
    	
    		aChave  := {'A1_FILIAL','A1_COD','A1_LOJA'}
    		cCampos := 'A1_COD, A1_LOJA, A1_NOME, A1_CONTA'
			oStruct := FWFormStruct(1, 'SA1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('*', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})    		
			oStruct:SetProperty('A1_CONTA', MODEL_FIELD_WHEN, Nil)    		
    		
    	Case oTFolder:nOption == NFORNECEDOR

    		aChave  := {'A2_FILIAL','A2_COD','A2_LOJA'}
    		cCampos := 'A2_COD, A2_LOJA, A2_NOME, A2_CONTA'
			oStruct := FWFormStruct(1, 'SA2', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('*', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})    		
			oStruct:SetProperty('A2_CONTA', MODEL_FIELD_WHEN, Nil)    		
		    
    	Case oTFolder:nOption == NPRODUTO

    		aChave  := {'B1_FILIAL','B1_COD'}
    		cCampos := 'B1_COD, B1_DESC, B1_CONTA, B1_CC, B1_ITEMCC, B1_CLVL'
			oStruct := FWFormStruct(1, 'SB1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('B1_COD',  MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
			oStruct:SetProperty('B1_DESC', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
    		
    	Case oTFolder:nOption == NNATUREZA
    	
    		aChave  := {'ED_FILIAL','ED_CODIGO'}
    		cCampos := 'ED_CODIGO, ED_DESCRIC, ED_CONTA'
			oStruct := FWFormStruct(1, 'SED', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('*', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
			oStruct:SetProperty('ED_CONTA', MODEL_FIELD_WHEN, Nil)    		
    		
    	Case oTFolder:nOption == NBANCO
    	
    		aChave  := {'A6_FILIAL','A6_CODIGO','A6_AGENCIA','A6_NUMCON'}
    		cCampos := 'A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME, A6_CONTA'
			oStruct := FWFormStruct(1, 'SA6', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('*', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
			oStruct:SetProperty('A6_CONTA', MODEL_FIELD_WHEN, Nil)    		

    	Case oTFolder:nOption == NENTIDADE

			aChave  := {cCtbaCpo + '_FILIAL', cCtbaCpo + '_CODIGO'}
			cCampos := cCtbaCpo + '_FILIAL,' + cCtbaCpo + '_CODIGO'
			oStruct := FWFormStruct(1, cCtbaTab)
    		
    	Case oTFolder:nOption == NATIVO

    		aChave  := {'N1_FILIAL','N1_CBASE','N1_ITEM'}
    		cCampos := 'N1_CBASE, N1_ITEM, N1_DESCRIC' 
			oStruct := FWFormStruct(1, 'SN1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)}) // Estrutura de Dados da Interface
		        		
			oStruct:SetProperty('*', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
			    		    		    	    		
	EndCase
               
    oModel  := MPFormModel():New("CTBAZ07M") //,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) //Instanciando o modelo   
       
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORM",/*cOwner*/,oStruct)                       
       
    //chave primária da rotina
    oModel:SetPrimaryKey(aChave)
		    
    //Descrição ao modelo
    oModel:SetDescription(CTITULO)
    
    //Descrição do formulário
    oModel:GetModel("FORM"):SetDescription(CTITULO)
    
    If oTFolder:nOption == NATIVO
    
    	SX3->(DbSetOrder(1))

		SX3->(MsSeek('SN3'))
		
		cCampos := 'N3_HISTOR,N3_DINDEPR,'
		
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'SN3'
		
			If SX3->X3_FOLDER == '2'
			
				cCampos += AllTrim(SX3->X3_CAMPO) + ','
		
			EndIf
			
			SX3->(DbSkip())
		
		EndDo
		
		cCampos := SubStr(cCampos, 1, Len(cCampos) - 1)    	    
    
    	oStrDet := FWFormStruct(1, 'SN3', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
				
		oStrDet:SetProperty('N3_HISTOR',  MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
		oStrDet:SetProperty('N3_DINDEPR', MODEL_FIELD_WHEN, {|a,b,c| FWInitCpo(a,b,c),lRet:=(INCLUI),FWCloseCpo(a,b,c,lRet,.T.),lRet})
		
		oModel:AddGrid('SN3DETAIL', 'FORM', oStrDet,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence    
    
		//Fazendo o relacionamento entre o Pai e Filho
		aAdd(aRelac, {'N3_FILIAL', 'xFilial("SN3")'})
    	aAdd(aRelac, {'N3_CBASE',  'N1_CBASE'})
    	aAdd(aRelac, {'N3_ITEM',   'N1_ITEM'})
    	
		oModel:SetRelation('SN3DETAIL', aRelac, SN3->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
		//oModel:GetModel('SN3DETAIL'):SetUniqueLine({'N3_FILIAL','N3_CBASE','N3_ITEM'})  //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    	oModel:SetPrimaryKey({})
     
    	//Setando as descrições
    	oModel:GetModel('SN3DETAIL'):SetDescription('Contabilização')
    	
    	//Não permite inclusão de linhas    	    	
    	oModel:GetModel('SN3DETAIL'):SetNoInsertLine( .T. )    	
    	 
    EndIf
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel    := FWLoadModel("CTBAZ07")
    Local oStruct   := Nil  
    Local oStrDet   := Nil    
    Local oView     := FWFormView():New()
    Local cAliasTmp := ''
    Local cCampos   := ''
	Local cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
	Local cCtbaCpo := ""  	
	
	cCtbaTab := AllTrim(cCtbaTab) + "3"    
	cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))				
    
    Do Case
    
    	Case oTFolder:nOption == NCLIENTE
    	
    		cCampos   := 'A1_COD, A1_LOJA, A1_NOME, A1_CONTA'    		
    		oStruct   := FWFormStruct(2, 'SA1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
    		
    	Case oTFolder:nOption == NFORNECEDOR
    	
    		cCampos   := 'A2_COD, A2_LOJA, A2_NOME, A2_CONTA'
    		oStruct   := FWFormStruct(2, 'SA2', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
    		
    	Case oTFolder:nOption == NPRODUTO

    		cCampos   := 'B1_COD, B1_DESC, B1_CONTA, B1_CC, B1_ITEMCC, B1_CLVL'
    		oStruct   := FWFormStruct(2, 'SB1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
    		
    	Case oTFolder:nOption == NNATUREZA
    	
    		cCampos   := 'ED_CODIGO, ED_DESCRIC, ED_CONTA'
    		oStruct   := FWFormStruct(2, 'SED', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
    		    		
    	Case oTFolder:nOption == NBANCO
    	
    		cCampos   := 'A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME, A6_CONTA'    
    		oStruct   := FWFormStruct(2, 'SA6', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  

    	Case oTFolder:nOption == NENTIDADE

			cCampos := cCtbaCpo + '_FILIAL,' + cCtbaCpo + '_CODIGO'
			oStruct := FWFormStruct(1, cCtbaTab)
    		    	    		
    	Case oTFolder:nOption == NATIVO

    		cCampos   := 'N1_CBASE, N1_ITEM, N1_DESCRIC'        		
    		oStruct   := FWFormStruct(2, 'SN1', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  		
		    
	EndCase
	    
    oStruct:SetNoFolder()
    
    oView:SetModel(oModel)

    //Formulário para interface
    oView:AddField("VIEW", oStruct, "FORM")
    
    If oTFolder:nOption == NATIVO
    
    	SX3->(DbSetOrder(1))

		SX3->(MsSeek('SN3'))
		
		cCampos := 'N3_HISTOR,N3_DINDEPR,'
		
		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == 'SN3'
		
			If SX3->X3_FOLDER == '2'
			
				cCampos += AllTrim(SX3->X3_CAMPO) + ','
		
			EndIf
			
			SX3->(DbSkip())
		
		EndDo
		
		cCampos := SubStr(cCampos, 1, Len(cCampos) - 1)    	    
    
    	oStrDet := FWFormStruct(2, 'SN3', {|cCampo| If(AllTrim(cCampo)$cCampos,.t.,.f.)})  
    
    	oView:AddGrid('VIEW_SN3', oStrDet, 'SN3DETAIL')
    	
		//Setando o dimensionamento de tamanho
		oView:CreateHorizontalBox('MASTER', 20)
		oView:CreateHorizontalBox('DETAIL', 80)
		
		//Amarrando a view com as box
		oView:SetOwnerView('VIEW',     'MASTER')
		oView:SetOwnerView('VIEW_SN3', 'DETAIL')
		
		oView:EnableTitleView('VIEW_SN3', 'Contabilização')
    
	Else
	    
	    //Container com nome tela com 100%
	    oView:CreateHorizontalBox("TELA",100)
	     
	    //Título do formulário
	    oView:EnableTitleView('VIEW', 'Dados da ' + CTITULO )  
	     
	    //Fechamento da janela na confirmação
	    oView:SetCloseOnOk({||.T.})
	     
	    //formulário da interface será colocado dentro do container
	    oView:SetOwnerView("VIEW","TELA")
	  
    EndIf
	    
Return oView

/*/{Protheus.doc} CTBAZ07
function getProField

@author DEV
@since 15/05/2019
@version ALL
/*/
Static Function getProField(aParams)

	Local aReturn := {}
	Local aField := {}
	Local nX := 0

	For nX := 1 To Len(aParams)

		aField  := {}	
		aAdd(aField, GetSx3Cache(aParams[nX], 'X3_TITULO'))
		aAdd(aField, aParams[nX])
		aAdd(aField, GetSx3Cache(aParams[nX], 'X3_TIPO'))
		aAdd(aField, GetSx3Cache(aParams[nX], 'X3_TAMANHO'))
		aAdd(aField, GetSx3Cache(aParams[nX], 'X3_TAMANHO'))
		aAdd(aField, GetSx3Cache(aParams[nX], 'X3_PICTURE'))
		aAdd(aReturn, aField)

	Next

Return aReturn