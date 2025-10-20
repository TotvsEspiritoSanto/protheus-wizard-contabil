#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo  := "Cadastro de Regras de Contabilização Fiscal"
Static cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaCpo := ""

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ02   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastro de regras de contabilização fiscal.                  |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ02()

    Local aArea     := GetArea()
    Local oBrowse   := Nil
    
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "0"
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,1), AllTrim(cCtbaTab)) + "0"
    
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
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ02" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ02" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ02" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ02" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ02" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ02" OPERATION 9                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local oStSZ0   := FWFormStruct(1, cCtbaTab)                                                     // Estrutura de Dados da Interface
    Local oModel   := MPFormModel():New("CTBAZ02M")//,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)   // Instanciando o modelo
       
    //Atribuindo formulários para o modelo
    oModel:AddFields("FORMSZ0",/*cOwner*/,oStSZ0)                       
    
    //chave primária da rotina
    oModel:SetPrimaryKey({cCtbaCpo + '_FILIAL', cCtbaCpo + '_CODIGO'})
 
    //Descrição ao modelo
    oModel:SetDescription(cTitulo)
    
    //Descrição do formulário
    oModel:GetModel("FORMSZ0"):SetDescription(cTitulo)
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel    := FWLoadModel("CTBAZ02")
    Local oStSZ0    := FWFormStruct(2, cCtbaTab)//,/*CodeBlock*/)  
    Local oView     := FWFormView():New()
    
    oView:SetModel(oModel)
    
    //Formulário para interface
    oView:AddField("VIEW_SZ0", oStSZ0, "FORMSZ0")
    
    //Container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Título do formulário
    oView:EnableTitleView('VIEW_SZ0', 'Dados da '+cTitulo )  
     
    //Fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_SZ0","TELA")
    
Return oView
