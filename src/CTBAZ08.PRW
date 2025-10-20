#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
Static cTitulo  := "Cadastro de Regras de Contabilização Genérica."
Static cCtbaTab := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaDet := GetMv("ZY_CTBATAB", .F., "")
Static cCtbaCpo := ""
Static cCtbaCpd := ""
 
/*/{Protheus.doc} CTBAZ08

/*/
 
User Function CTBAZ08()
    Local aArea   := GetArea()
    Local oBrowse
     
    If Empty(cCtbaTab)
    
    	MsgStop("Parâmetro ZY_CTBATAB não encontrado, este parametro contém o prefixo das tabelas que serão utilizadas por essa rotina. Favor cria-lo antes de executar essa rotina!")
    	
    	Return Nil
    
    EndIf
    
    cCtbaTab := AllTrim(cCtbaTab) + "4"    
    cCtbaDet := AllTrim(cCtbaDet) + "5"    
    cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))	
    cCtbaCpd := If(SubStr(cCtbaDet, 1, 1) == "S", SubStr(AllTrim(cCtbaDet),2,2), AllTrim(cCtbaDet))	
     
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias(cCtbaTab)
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()
     
    RestArea(aArea)
Return Nil

Static Function MenuDef()

    Local aRotina := {}
    
    ADD OPTION aRotina Title "Visualizar"   ACTION "VIEWDEF.CTBAZ08" OPERATION MODEL_OPERATION_VIEW  ACCESS 0
    ADD OPTION aRotina Title 'Incluir'      ACTION "VIEWDEF.CTBAZ08" OPERATION 3                     ACCESS 0
    ADD OPTION aRotina Title 'Alterar'      ACTION "VIEWDEF.CTBAZ08" OPERATION 4                     ACCESS 0
    ADD OPTION aRotina Title 'Excluir'      ACTION "VIEWDEF.CTBAZ08" OPERATION 5                     ACCESS 0
    ADD OPTION aRotina Title 'Imprimir'     ACTION "VIEWDEF.CTBAZ08" OPERATION 8                     ACCESS 0
    ADD OPTION aRotina Title 'Copiar'       ACTION "VIEWDEF.CTBAZ08" OPERATION 9                     ACCESS 0

	Aadd(aRotina, { "Replicar", "U_COPYZ08", 0, 4, 2 ,.F. } ) // "Replicar para outra filial

Return aRotina

// 	Local aRot := FWMVCMenu("CTBAZ08")
// Return aRot
 
Static Function ModelDef()
    Local oModel   := Nil
    Local oStPai   := FWFormStruct(1, cCtbaTab)
    Local oStFilho := FWFormStruct(1, cCtbaDet)
    Local aRel     := {}
        
    oModel := MPFormModel():New('CTBAZ08M')
    oModel:AddFields('MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('DETAIL','MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner é para quem pertence
     
    aAdd(aRel, {cCtbaCpd + '_FILIAL', "FwXFilial('"+ cCtbaTab +"')"})
    aAdd(aRel, {cCtbaCpd + '_SIGLA',  cCtbaCpo + '_SIGLA'})
    aAdd(aRel, {cCtbaCpd + '_SEQUEN', cCtbaCpo + '_SEQUEN'})
     
    oModel:SetRelation('DETAIL', aRel, &(cCtbaDet)->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
    oModel:GetModel('DETAIL'):SetUniqueLine({cCtbaCpd + "_FILIAL", cCtbaCpd + "_SIGLA", cCtbaCpd + "_SEQUEN", cCtbaCpd + "_ITEM"})    //Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({})
     
    oModel:SetDescription("Regra de Contabilização Genérica.")
    oModel:GetModel('MASTER'):SetDescription('Regra')
    oModel:GetModel('DETAIL'):SetDescription('Condições')
Return oModel
 
Static Function ViewDef()
    Local oView    := Nil
    Local oModel   := FWLoadModel('CTBAZ08')
    Local oStPai   := FWFormStruct(2, cCtbaTab)
    Local oStFilho := FWFormStruct(2, cCtbaDet)
     
    oView := FWFormView():New()
    oView:SetModel(oModel)
     
    oView:AddField('VIEW_SZ4',oStPai,'MASTER')
    oView:AddGrid('VIEW_SZ5',oStFilho,'DETAIL')
     
    oView:CreateHorizontalBox('CABEC',40)
    oView:CreateHorizontalBox('GRID',60)
     
    oView:SetOwnerView('VIEW_SZ4','CABEC')
    oView:SetOwnerView('VIEW_SZ5','GRID')
          
    oView:SetCloseOnOk({||.T.})
    
    oView:AddIncrementField( 'VIEW_SZ5', cCtbaCpd + '_ITEM' )
     
    oStFilho:RemoveField(cCtbaCpd + '_SIGLA')
    oStFilho:RemoveField(cCtbaCpd + '_SEQUEN')
Return oView
 





//-------------------------------------------------------------------
/*/{Protheus.doc} CopyTES
função para Marcar TES e copiar para diversas Filiais

@author Rafael dos Santos
@since 20.12.2017
@version 1.0

/*/
//-------------------------------------------------------------------
User Function COPYZ08()

    Local aColumns		:= {}
    Local nX			:= 0 
    Local cAliasCab		:= GetNextAlias()
    Local oDialogMK	 	:= Nil
    Local oMrkBrowse 	:= Nil
    Local cAliasTemp	:= " "
    Local cSlctSF4		:= "% "
    Local lMarcar  		:= .F.
    Local aStructTrb 	:= &(cCtbaTab + "->(DbStruct())")
    Local aCampoGrid 	:= {cCtbaCpo + "_SIGLA", cCtbaCpo + "_SEQUEN", cCtbaCpo + "_DESCRI"}
    Local aSeek			:= {}
    Local aFiltro		:= {}
    Local cIndice1,cIndice2	:= ""
    Local aRetCopy   	:= If(Type("aRotina")=="A",ACLONE(aRotina),{})

    //Define Menu
    aRotina := {}

    For nX:=1 To Len(aStructTrb)  //Colunas que serão exibidas no browse
        If !aStructTrb[nX][1]=="MARK" .And. Ascan(aCampoGrid,aStructTrb[nX][1])>0
            AAdd(aColumns,FWBrwColumn():New())
            aColumns[Len(aColumns)]:SetData( &("{||"+aStructTrb[nX][1]+"}") )
            aColumns[Len(aColumns)]:SetTitle(RetTitle(aStructTrb[nX][1])) 
            aColumns[Len(aColumns)]:SetSize(aStructTrb[nX][3]) 
            aColumns[Len(aColumns)]:SetDecimal(aStructTrb[nX][4])
            aColumns[Len(aColumns)]:SetPicture(PesqPict("SF4",aStructTrb[nX][1]))
            
            aAdd(aFiltro	,{aStructTrb[nX][1];
                ,aStructTrb[nX][1];
                ,aStructTrb[nX][2];
                ,aStructTrb[nX][3];
                ,aStructTrb[nX][4];
                ,PesqPict("SFM",aStructTrb[nX][1])})
                
        EndIf
        //Query SF4
        cSlctSF4 += aStructTrb[nX,1]+", "
    Next nX

    //Query SF4
    cSlctSF4 += "' ' AS MARK "
    cSlctSF4 += "%"

    cFilTmp := xFilial(cCtbaTab)
    cTabTmp := "% " + RetSqlName(cCtbaTab) + " %"
    cCpoFil := "% " + cCtbaCpo + "_FILIAL %"
    cCpoOrd := "% " + cCtbaCpo + "_SIGLA, " + cCtbaCpo + "_SEQUEN %"

    BeginSql Alias cAliasCab	
        SELECT
            %Exp:cSlctSF4%
        FROM 
            %Exp:cTabTmp% TMP
        WHERE
            TMP.%Exp:cCpoFil% = %Exp:cFilTmp% AND
            TMP.%NotDel%
        ORDER BY TMP.%Exp:cCpoOrd%
    EndSql

    //Cria arquivo temporário
    cAliasTemp := CriaTrab(aStructTrb,.T.)
    Copy To &cAliasTemp

    //Fecha query
    If Select(cAliasCab) > 0
        DbSelectArea(cAliasCab)
        DbCloseArea()
    EndIf

    //Criar indices
    cIndice1 := Alltrim(CriaTrab(,.F.))

    //Se indice existir excluir
    If File(cIndice1+OrdBagExt())
        FErase(cIndice1+OrdBagExt())
    EndIf

    DbUseArea( .T.,,cAliasTemp,cAliasTemp, .T., .F. )

    //índice temporário
    IndRegua(cAliasTemp, cIndice1, cCtbaCpo + "_SIGLA + " + cCtbaCpo + "_SEQUEN",,, "CODIGO")

    //Fecha todos os índices da área de trabalho
    dbClearIndex()

    //Acrescenta índice
    dbSetIndex(cIndice1+OrdBagExt())

    //Inicia Browse
    If !(cAliasTemp)->(Eof())

        aAdd(aSeek,{"CODIGO",{{"","C",003,0,"CODIGO","@!"}} } )

        oMrkBrowse := FWMarkBrowse():New()	
        oMrkBrowse:SetOwner(oDialogMK)
        oMrkBrowse:SetDescription("Replicar")
        
        oMrkBrowse:SetMenuDef("")
        oMrkBrowse:ForceQuitButton()
        oMrkBrowse:DisableConfig(.F.)
        oMrkBrowse:DisableReport(.F.)
        oMrkBrowse:DisableDetails(.T.)
        oMrkBrowse:SetWalkThru(.F.)			

        oMrkBrowse:oBrowse:SetUseFilter(.T.)
        oMrkBrowse:oBrowse:SetDBFFilter() 
        oMrkBrowse:oBrowse:SetFieldFilter(aFiltro)
        oMrkBrowse:oBrowse:SetSeek(.T.,aSeek)

        oMrkBrowse:SetAlias(cAliasTemp)	
        oMrkBrowse:SetColumns(aColumns)

        oMrkBrowse:SetFieldMark("MARK")
        oMrkBrowse:SetMark('X', cAliasTemp, "MARK")
        oMrkBrowse:SetAllMark( { || .T. } )
        oMrkBrowse:bAllMark := { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.F. ), oMrkBrowse:Refresh(.T.)  }

        oMrkBrowse:AddButton("Copiar", { || FwMsgRun(,{|oSay|CopyZ08R(cAliasTemp,.T.)},'Processando',"",),Alert("Processo Finalizado"),oMrkBrowse:GetOwner():End()},,2 )
        oMrkBrowse:AddButton("Inverter Seleção", { || InvertSel(cAliasTemp,oMrkBrowse:Mark(),lMarcar := !lMarcar,.T. ),oMrkBrowse:Refresh(.T.)},,2 )	
        oMrkBrowse:AddButton("Cancelar", { || oMrkBrowse:GetOwner():End()},,2 )

        oMrkBrowse:Activate()
        
    Else
        Help(" ",1,"RECNO")
    EndIf


    //Se indice existir excluir
    If File(cIndice1+OrdBagExt())
        FErase(cIndice1+OrdBagExt())
    EndIf

    //Limpar o arquivo temporário
    If !Empty(cAliasTemp)
        Ferase(cAliasTemp+GetDBExtension())
        Ferase(cAliasTemp+OrdBagExt())	
        (cAliasTemp)->(DbCloseArea())
        cAliasTemp:=""
    Endif

    //Restaura Menu
    aRotina:=AClone(aRetCopy)

Return


/*-------------------------------------------------------------------
{Protheus.doc} InvertSel
Regra para marcação dos registros de notas

@author Rafael S Oliveira
@since 20/12/2017
@version 1.0
-------------------------------------------------------------------*/
Static Function InvertSel(cAliasCab,cMarca,lMarcar, lInvert)
Local aAreaSF4  := (cAliasCab)->( GetArea() )

(cAliasCab)->( dbGoTop() )
While !(cAliasCab)->( Eof() )
	RecLock( (cAliasCab), .F. )
	
	If lInvert
		(cAliasCab)->MARK := IIf( (cAliasCab)->MARK == cMarca , '  ',cMarca )
	Else
		(cAliasCab)->MARK := IIf( lMarcar, cMarca, '  ' )
	Endif
	
	MsUnlock()
	(cAliasCab)->( dbSkip() )
EndDo

RestArea( aAreaSF4 )
Return .T.







//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CopySF4

@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cAliasQry, Caracter, Alias da Query executada na SF4, com TES selecionados para realizar a cópia
@description Função que irá realizar a cópia da SF4 para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function CopyZ08R(cAliasQry,lMark)
Local aEstrut	:= (cAliasQry)->(dbStruct()) //Monta estrutura
Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= {}
Local cTabela	:= cCtbaTab
Local cFilCad	:= cFilAnt
Local cEmpCad	:= cEmpAnt
Local nCont		:= 0
Local lProc		:= .T.
Local nHandle	:= CriaTxtLog()

Local cAliasDet := GetNextAlias()
Local cFilTmp   := xFilial(cCtbaDet)
Local cSigTmp   := ""
Local cSeqTmp   := ""
Local cTabTmp   := "% " + RetSqlName(cCtbaDet) + " %"
Local cCpoFil   := "% " + cCtbaCpd + "_FILIAL %"
Local cCpoSig   := "% " + cCtbaCpd + "_SIGLA %"
Local cCpoSeq   := "% " + cCtbaCpd + "_SEQUEN %"
Local cCpoOrd   := "% " + cCtbaCpd + "_SIGLA, " + cCtbaCpd + "_SEQUEN %"

Default lMark := .F.

If lMark	
	aSm0 	:= MatFilCalc( .T.,,,,,,.T. ) //Seleciona Filial
	IndRegua (cAliasQry,cAliasQry,cCtbaCpo + "_SIGLA + " + cCtbaCpo + "_SEQUEN",,"MARK=='X'")	// Filtra somente registros marcados
Else	
	aSm0 	:= MatFilCalc( .F.,,,,,,.T. )
Endif

//Inicia transação
Begin Transaction
		
//Laço nas filiais da empresa logada
For nCont := 1 to Len(aSm0)
	
	If lMark
		//Processa somente Filiais Marcadas
		lProc := aSm0[nCont][1]
	Else
		//Processa Todas Filiais
		lProc := .T.
	Endif
	
	If lProc
		SM0->(DbGoTop ())
		SM0->(MsSeek (cEmpCad+aSm0[nCont][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL		
		
		//A filial logada é desconsiderada
		IF cFilAnt <> cFilCad
		
			//Laço de TES que serão copiados para as filiais			
			(cAliasQry)->(DbGoTop())			
						
			While !(cAliasQry)->(Eof())
				
				//Verifica se o TES já existe na filial de destino, somente irá incluir se não existir					
                // If &("!(" + cCtbaTab + "->(MsSeek(xFilial('" + cCtbaTab + "') + (cAliasQry)->(" + cCtbaCpo + "_SIGLA + " + cCtbaCpo + "_SEQUEN))))")
				// IF !SF4->(MsSeek(xFilial("SF4")+ (cAliasQry)->F4_CODIGO))	
                If !&(cTabela)->(MsSeek(xFilial(cTabela) + (cAliasQry)->(&(cCtbaCpo + "_SIGLA") + &(cCtbaCpo + "_SEQUEN"))))
                    // If &("!SZ4->(MsSeek(xFilial('SZ4') + (cAliasQry)->(Z4_SIGLA + Z4_SEQUEN)))")
					//Função que realizar cópia para filial de destino

                    cSigTmp   := "% '" + (cAliasQry)->(&(cCtbaCpo + "_SIGLA")) + "' %"
                    cSeqTmp   := "% '" + (cAliasQry)->(&(cCtbaCpo + "_SEQUEN")) + "' %"

                    BeginSql Alias cAliasDet	
                        SELECT 
                            TMP.*
                        FROM 
                            %Exp:cTabTmp% TMP
                        WHERE
                            TMP.%Exp:cCpoFil% = %Exp:cFilTmp% AND
                            TMP.%Exp:cCpoSig% = %Exp:cSigTmp% AND
                            TMP.%Exp:cCpoSeq% = %Exp:cSeqTmp% AND 
                            TMP.%NotDel%
                        ORDER BY TMP.%Exp:cCpoOrd%
                    EndSql


					GrvTab(aEstrut, cAliasQry, cTabela, nHandle, lMark, cAliasDet)	

                    (cAliasDet)->(DbCloseArea())

				EndiF
						
				(cAliasQry)->(dbSkip())			
			EndDo				
		EndIF
	EndIF
	
Next nCont


//Fecha alias e restaura filial logada
IF lMark
	//Limpa Objeto e Arquivo Temporario
	If !Empty(cAliasQry)    
		Ferase(cAliasQry+GetDBExtension())
		Ferase(cAliasQry+OrdBagExt())
		cAliasQry := ""
	Endif	
Else
	(cAliasQry)->(DbCloseArea ())
Endif

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

If (nHandle>=0)
	FClose (nHandle)
Endif

//Fecha transação 		
End Transaction

Return .T.

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GrvTab
 
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param aEstrut, Array, Estrutura da tabela que será copiada
@param cAliasQry, Caracter, Alias da Query executada da tabela que será copiada
@param cTabela, Caracter, Nome da tabela que será copiada
@description Função que irá realizar a cópia da SF4 para demais filiais 

/*/
//----------------------------------------------------------------------------------------------------
Static Function GrvTab(aEstrut, cAliasQry, cTabela, nHandle, lMark, cAliasDet)

Local nCont    := 0
Local cLinha   := ''
Local aEstrDet := (cAliasDet)->(DbStruct())

//Inclui nova linha na tabela
RecLock(cTabela,.T.)

//Gravação do campo _FILIAL será sempre com retorno do xFilial()
&(cTabela + "->" + Iif(Substr(cTabela,1,1) == 'S', Substr(cTabela,2,2) ,cTabela )   + "_FILIAL" ) := xFilial(cTabela)

//Laço nos campos da tabela estrutura do SX3
For nCont := 1 to Len(aEstrut)

	//Ignora campo de Marcação
	If lMark .And. aEstrut[nCont][1] =='MARK'
		Loop
	Endif
	
	If aEstrut[nCont][2] <> 'M'
	
		//Para campo tipo Date preciso utilizar a função TcSetField para que não ocorra erro de Type Mismatch
		If aEstrut[nCont][2] == 'D'		
			TcSetField(cAliasQry,aEstrut[nCont][1],"D",8,0)
		EndiF
		
		//Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
		If ! "FILIAL"  $ aEstrut[nCont][1]
			&(cTabela + "->" +aEstrut[nCont][1] )	:= 	(cAliasQry)->&(aEstrut[nCont][1])	
		EndIF
		
	EndIf
	
Next nCont

(cTabela)->(MsUnLock())

/*
GRAVA TABELA DE DETALHES.
*/
While (cAliasDet)->(!Eof())

    //Inclui nova linha na tabela
    RecLock(cCtbaDet,.T.)

    //Gravação do campo _FILIAL será sempre com retorno do xFilial()
    &(cCtbaDet + "->" + Iif(Substr(cCtbaDet,1,1) == 'S', Substr(cCtbaDet,2,2) ,cCtbaDet )   + "_FILIAL" ) := xFilial(cCtbaDet)

    //Laço nos campos da tabela estrutura do SX3
    For nCont := 1 to Len(aEstrDet)

        //Ignora campo de Marcação
        If lMark .And. aEstrDet[nCont][1] =='MARK'
            Loop
        Endif
        
        If aEstrDet[nCont][2] <> 'M'
        
            //Para campo tipo Date preciso utilizar a função TcSetField para que não ocorra erro de Type Mismatch
            If aEstrDet[nCont][2] == 'D'		
                TcSetField(cAliasDet,aEstrDet[nCont][1],"D",8,0)
            EndiF
            
            //Campo Filial não será copiado, já foi gravado anteriormente com conteúdo do xFilial
            If ! "FILIAL" $ aEstrDet[nCont][1] .And. ! AllTrim(aEstrDet[nCont][1]) $ "R_E_C_N_O_/D_E_L_E_T_/R_E_C_D_E_L_"
                &(cCtbaDet + "->" +aEstrDet[nCont][1] )	:= 	(cAliasDet)->&(aEstrDet[nCont][1])	
            EndIF
            
        EndIf
        
    Next nCont

    (cCtbaDet)->(MsUnLock())

    (cAliasDet)->(DbSkip())

EndDo

cLinha := 'Regra contábil replicada para Grupo de Empresa: ' + FWGrpCompany()
cLinha += Iif(FWModeAccess(cCtbaTab,1) == 'C' .OR. Empty(Alltrim(FWCompany())) ,''    , ', Empresa: ' + FWCompany()  )
cLinha += Iif(FWModeAccess(cCtbaTab,2) == 'C' .OR. Empty(Alltrim(FWUnitBusiness())) ,''  , ', Unidade de Negócio: ' + FWUnitBusiness()  )
cLinha += Iif(FWModeAccess(cCtbaTab,3) == 'C' .OR. Empty(Alltrim(FWFilial())),''  , ' e Filial ' + FWFilial()  )
cLinha +=' : Sigla = '			+ (cAliasQry)->(&(cCtbaCpo + "_SIGLA"))
cLinha +=', Sequencia = '		+ (cAliasQry)->(&(cCtbaCpo + "_SEQUEN"))
cLinha +=', Descrição = ' 		+ (cAliasQry)->(&(cCtbaCpo + "_DESCRI")) + ' '
cLinha += Chr (13)+Chr (10)

FWrite (nHandle, cLinha, Len (cLinha))

Return

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} QrySF4
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@param cCodSF4, Caracter, Estrutura da tabela que será copiada
@return	cAliasSF4, Caracter, Query realizada na SF4
@description Função que faz seleção do código de TES que deverá ser copiado 

/*/
//----------------------------------------------------------------------------------------------------
Static Function QrySF4(cCodSF4)

Local cAliasSF4	:= "SF4"
Local cSlctSF4	:= ''

cSlctSF4 :='%'
cSlctSF4 += 'SF4.* ' //Preciso trazer todos os campos da SF4, por este motivo utilizo asterísco.
cSlctSF4 +='%'
   	
cAliasSF4	:=	GetNextAlias()
   	
BeginSql Alias cAliasSF4	
	SELECT			    
		%Exp:cSlctSF4%
	FROM 
		%Table:SF4% SF4
	WHERE
		SF4.F4_FILIAL=%xFilial:SF4% AND		
		SF4.F4_CODIGO=%Exp:cCodSF4% and
		SF4.%NotDel%	
EndSql

Return cAliasSF4

//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldReplica
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função que faz validação se  tes  já existe em alguma filial 

/*/
//----------------------------------------------------------------------------------------------------
Static Function VldReplica(cCodTEs)

Local aAreaSM0  := SM0->(GetArea())
Local aSm0		:= MatFilCalc( .F.,,,,,,.T. )
Local nCont		:= 0
Local cMsg		:= ''
Local cEmpCad	:= cEmpAnt
Local cFilCad	:= cFilAnt

For nCont := 1 to Len(aSm0)

	SM0->(DbGoTop ())
	SM0->(MsSeek (cEmpCad+aSm0[nCont][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL	
	
	//A filial logada é desconsiderada
	IF cFilAnt <> cFilCad
				
		//Verifica se o TES já existe na filial de destino, somente irá incluir se não existir
		IF  SF4->(MsSeek(xFilial("SF4")+ cCodTEs))	
			cMsg	+= 'TES  já existe na filial: ' + cFilAnt 	+ chr(13)+chr(10)
		EndiF
		
	EndIF

Next nCont

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return cMsg



//---------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTxtLog
@author Erick G. Dias
@since 04/05/2017
@version 12.1.7
@description Função responsável por criar diretório e arquivo de log.	  

/*/
//----------------------------------------------------------------------------------------------------
Static Function CriaTxtLog()

Local cDiretorio	:=  GetSrvProfString("Startpath","") + 'CTBACOPY'

IF ! ExistDir( cDiretorio ) 
	MakeDir( cDiretorio )
EndIF

Return FCREATE(cDiretorio + '\COPY_CTBAZ08_' + StrTran(DtoC(dDataBase), "/","")+'_'+ StrTran(Time(), ":","" )+'.TXT', 0)

