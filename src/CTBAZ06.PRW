#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

Static cTitulo  := "Contas contábeis da folha de pagamento."
Static cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaCpo := ""

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ06   | Autor |Kenny Roger Martins    | Data | 13.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Contas contábeis da folha de pagamento.                       |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ06()

	Local aCoors := FWGetDialogSize( oMainWnd )
  	Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft,oBrowseRight, oRelac
		
	Private oDlgPrinc
	Private cCadastro := cTitulo
	
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "3"    
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))	

	oDlgPrinc := MSDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 
		  	
	//
	// Cria o conteiner onde serão colocados os browses
	//
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
		
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
  	
	oDlgPrinc:Activate( , , , , , , EnchoiceBar( oDlgPrinc, {|| }, { || oDlgPrinc:End() }, , {}, , , , , .F., .F. ) ) //ativa a janela criando uma enchoicebar
		
Return NIL

/*---------+----------+-------+-----------------------+------+------------+
|Função    |MenuDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Menu da Rotina                                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ06" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ06" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ06" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ06" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ06" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ06" OPERATION 9                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local bPos    := {|oModel| fieldValidPos(oModel)}
    Local oStruct := FWFormStruct(1, cCtbaTab) // Estrutura de Dados da Interface
    Local oModel  := MPFormModel():New("CTBAZ06M",,bPos)//,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) //Instanciando o modelo
       
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORM",/*cOwner*/,oStruct)                       
       
    //chave primária da rotina
    oModel:SetPrimaryKey({cCtbaCpo + '_FILIAL', cCtbaCpo + '_VERBA', cCtbaCpo + '_CUSTO'})
 
    //Descrição ao modelo
    oModel:SetDescription(cTitulo)
    
    //Descrição do formulário
    oModel:GetModel("FORM"):SetDescription(cTitulo)
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel    := FWLoadModel("CTBAZ06")
    Local oStruct   := FWFormStruct(2, cCtbaTab)//,/*CodeBlock*/)  
    Local oView     := FWFormView():New()
    
    oView:SetModel(oModel)
    
    //Formulário para interface
    oView:AddField("VIEW", oStruct, "FORM")
    
    //Container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Título do formulário
    oView:EnableTitleView("VIEW", "Dados da " + cTitulo )  
     
    //Fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //formulário da interface será colocado dentro do container
    oView:SetOwnerView("FORM", "TELA")
    
Return oView

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function fieldValidPos(oModel)

	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
   
	If nOperation == MODEL_OPERATION_INSERT
	    
	    If !ExistChav(cCtbaTab, oModel:GetValue("FORM", cCtbaCpo + "_VERBA") + oModel:GetValue("FORM", cCtbaCpo + "_CUSTO"))
										    
			lRet := .F.      
		      
		EndIf
		
	EndIf
	   
Return lRet 
