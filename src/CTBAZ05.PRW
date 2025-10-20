#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo  := "Cadastro de Entidade Contábil Padrão."
Static cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaCpo := ""

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ05   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastro de entidades contábeis padrão.                       |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ05()

    Local aArea	:= GetArea()
    Local oBrowse := Nil
    
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "2"    
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))
    
    //Inicia o FwBrowse de acordo com o dicionário de Dados
    
    oBrowse := FWMBrowse():New()
    
    oBrowse:SetAlias(cCtbaTab)
    oBrowse:SetDescription(cTitulo)
         
    oBrowse:Activate()
    
    RestArea(aArea)

Return oBrowse


/*---------+----------+-------+-----------------------+------+------------+
|Função    |MenuDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Menu da Rotina                                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ05" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ05" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ05" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ05" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ05" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ05" OPERATION 9                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local oStSZ2 := Nil // Estrutura de Dados da Interface
    Local bPos   := Nil
    Local oModel := Nil // ,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) //Instanciando o modelo

    If Len(AllTrim(cCtbaTab)) == 2

        cCtbaTab := AllTrim(cCtbaTab) + "2"    
        cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))

    EndIf

    oStSZ2 := FWFormStruct(1, cCtbaTab) // Estrutura de Dados da Interface
    bPos   := {|oModel| fieldValidPos(oModel)}
    oModel := MPFormModel():New("CTBAZ05M",,bPos)//,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) //Instanciando o modelo
       
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSZ2",/*cOwner*/,oStSZ2)                       
       
    //chave primária da rotina
    oModel:SetPrimaryKey({cCtbaCpo + '_FILIAL', cCtbaCpo + '_CODIGO'})
 
    //Descrição ao modelo
    oModel:SetDescription(cTitulo)
    
    //Descrição do formulário
    oModel:GetModel("FORMSZ2"):SetDescription(cTitulo)
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel := Nil
    Local oStSZ2 := Nil
    Local oView  := Nil
    
    If Len(AllTrim(cCtbaTab)) == 2

        cCtbaTab := AllTrim(cCtbaTab) + "2"    
        cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))

    EndIf

    oModel := FWLoadModel("CTBAZ05")
    oStSZ2 := FWFormStruct(2, cCtbaTab)//,/*CodeBlock*/)  
    oView  := FWFormView():New()
    
    oView:SetModel(oModel)
    
    //Formulário para interface
    oView:AddField("VIEW_SZ2", oStSZ2, "FORMSZ2")
    
    //Container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Título do formulário
    oView:EnableTitleView('VIEW_SZ2', 'Dados da ' + cTitulo )  
     
    //Fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZ2","TELA")
    
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
	    
	    If !ExistChav(cCtbaTab, oModel:GetValue("FORMSZ2", cCtbaCpo + "_CODIGO"))
										    
			lRet := .F.      
		      
		EndIf
		
	EndIf
	   
Return lRet 
