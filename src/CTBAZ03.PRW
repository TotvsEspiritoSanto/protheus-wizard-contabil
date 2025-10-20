#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo  := "Cadastro de Regras de Contabilização Financeira"
Static cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaCpo := ""

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ03   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastro de regras de contabilização financeira.              |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ03()

    Local aArea     := GetArea()
    Local oBrowse   := Nil
    
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "1"    
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))
    
    //Inicia o FwBrowse de acordo com o dicionário de Dados
    
    oBrowse := FWMBrowse():New()
    
    oBrowse:SetAlias(cCtbaTab)
    oBrowse:SetDescription(cTitulo)
         
    oBrowse:Activate()
    
    RestArea(aArea)

Return Nil


/*---------+----------+-------+-----------------------+------+------------+
|Função    |MenuDef   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Menu da Rotina                                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ03" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ03" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ03" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ03" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ03" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ03" OPERATION 9                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local oStSZ1  := FWFormStruct(1, cCtbaTab) // Estrutura de Dados da Interface
    Local bPos := {|oMdl| fieldValidPos(oMdl)}
    Local oModel  := MPFormModel():New("CTBAZ03M",,bPos)//,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) //Instanciando o modelo
       
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSZ1",/*cOwner*/,oStSZ1)                       
       
    //chave primária da rotina
    oModel:SetPrimaryKey({ cCtbaCpo + '_FILIAL', cCtbaCpo + '_SIGLA', cCtbaCpo + '_SEQUEN'})
 
    //Descrição ao modelo
    oModel:SetDescription(cTitulo)
    
    //Descrição do formulário
    oModel:GetModel("FORMSZ1"):SetDescription(cTitulo)
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel    := FWLoadModel("CTBAZ03")
    Local oStSZ1    := FWFormStruct(2, cCtbaTab)//,/*CodeBlock*/)  
    Local oView     := FWFormView():New()
    
    oView:SetModel(oModel)
    
    //Formulário para interface
    oView:AddField("VIEW_SZ1", oStSZ1, "FORMSZ1")
    
    //Container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Título do formulário
    oView:EnableTitleView('VIEW_SZ1', 'Dados da ' + cTitulo )  
     
    //Fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZ1","TELA")
    
Return oView

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function fieldValidPos(oModel)

	Local lRet := .T.
	Local nOperation := oModel:GetOperation()
   
	If nOperation == MODEL_OPERATION_INSERT
	    
	    If !ExistChav(cCtbaTab, oModel:GetValue("FORMSZ1", cCtbaCpo + "_SIGLA") + oModel:GetValue("FORMSZ1", cCtbaCpo + "_SEQUEN"))
										    
			lRet := .F.      
		      
		EndIf
		
	EndIf
	   
Return lRet 
