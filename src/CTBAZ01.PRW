#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static  cTitulo := "Cadastro Lançamentos Padronizados"

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ01   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastro de lançamento padrão.                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function CTBAZ01()

    Local aArea     := GetArea()
    Local oBrowse   := Nil
    
    //Inicia o FwBrowse de acordo com o dicionário de Dados
    
    oBrowse := FWMBrowse():New()
    
    oBrowse:SetAlias("CT5")
    oBrowse:SetDescription(cTitulo)
    
    //Legendas
    
    oBrowse:AddLegend( "CT5->CT5_STATUS == '1'", "GREEN", "Ativo"   )
    oBrowse:AddLegend( "CT5->CT5_STATUS == '2'", "RED",   "Inativo" )
     
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
    
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.CTBAZ01" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ01" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ01" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ01" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ01" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ01" OPERATION 9                     ACCESS 0

Return aRotina

/*---------+----------+-------+-----------------------+------+------------+
|Função    |ModelDef  | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | Modelo de Dados MVC                                          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
Static Function ModelDef()

    Local oStCT5   := FWFormStruct(1,"CT5")                                                       // Estrutura de Dados da Interface
    Local oModel   := MPFormModel():New("CTBAZ01M")//,/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/)   //Instanciando o modelo
       
    //Atribuindo formulários para o modelo 
    oModel:AddFields("FORMCT5",/*cOwner*/,oStCT5)                       
    
    //chave primária da rotina
    oModel:SetPrimaryKey({'CT5_FILIAL','CT5_LANPAD','CT5_SEQUEN'})
 
    //Descrição ao modelo
    oModel:SetDescription(cTitulo)
    
    //Descrição do formulário
    oModel:GetModel("FORMCT5"):SetDescription(cTitulo)
          
Return oModel
     
/*---------+----------+-------+-----------------------+------+------------+
|Função    |ViewDef   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição | View do Modelo de Dados                                      |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/   
Static Function ViewDef()

    Local oModel    := FWLoadModel("CTBAZ01")
    Local oStCT5    := FWFormStruct(2, "CT5")//,/*CodeBlock*/)  
    Local oView     := FWFormView():New()
    
    oView:SetModel(oModel)
    
    //Formulário para interface
    oView:AddField("VIEW_CT5", oStCT5, "FORMCT5")
    
    //Container com nome tela com 100%
    oView:CreateHorizontalBox("TELA",100)
     
    //Título do formulário
    oView:EnableTitleView('VIEW_CT5', 'Dados da '+cTitulo )  
     
    //Fechamento da janela na confirmação
    oView:SetCloseOnOk({||.T.})
     
    //formulário da interface será colocado dentro do container
    oView:SetOwnerView("VIEW_CT5","TELA")
    
Return oView
