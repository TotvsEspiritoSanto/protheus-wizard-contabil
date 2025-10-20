#Include 'Protheus.ch'

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOFIS   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Retorna conta conforme regra fiscal                           |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOFIS(cTipo)

	Local cCtbaTab := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "0"
	Local cCtbaCpo := If(SubStr(cCtbaTab, 1, 1) == "S", SubStr(AllTrim(cCtbaTab),2,2), AllTrim(cCtbaTab))
	Local cConta   := ""
	Local cCampo   := cCtbaCpo + "_" + Upper(AllTrim(cTipo))
	Local aAreaSX3 := SX3->(GetArea())

	SX3->(DbSetOrder(2))

	&(cCtbaTab)->(DbSetOrder(1))
	
	If &(cCtbaTab)->(MsSeek(xFilial(cCtbaTab) + SF4->F4_YREGCON))

		If SX3->(DbSeek(cCampo))
	
			cConta := &(cCtbaTab)->(FieldGet(FieldPos(cCampo)))

		Else

			MsgStop("Favor verificar a regra " + AllTrim(SF4->F4_YREGCON) + ", pois o campo " + cCampo + " não existe!")
			cConta := ""

		EndIf
	
	EndIf
	
	cConta := &cConta
	
	If Empty(cConta)
	
		cConta := "SEM CONTA REGRA " + SF4->F4_YREGCON
		
	EndIf

	RestArea(aAreaSX3)

Return cConta

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOFIN   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Retorna conta conforme regra financeira                       |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOFIN(cSigla, cTipo, cPartida)

	Local cCtbaTb1 := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "1"
	Local cCtbaCp1 := If(SubStr(cCtbaTb1, 1, 1) == "S", SubStr(AllTrim(cCtbaTb1),2,2), AllTrim(cCtbaTb1))	
	Local cCtbaTb2 := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "2"
	Local cCtbaCp2 := If(SubStr(cCtbaTb2, 1, 1) == "S", SubStr(AllTrim(cCtbaTb2),2,2), AllTrim(cCtbaTb2))	
	Local cRetorno := ""
	Local nRecFull := 0
	Local nRecNull := 0
	
	Default cSigla    := ""
	Default cTipo     := ""
	Default cPartida  := "3"

	&(cCtbaTb1)->(DbSetOrder(1))
	
	&(cCtbaTb1)->(MsSeek(xFilial(cCtbaTb1) + Padr(cSigla, TamSX3(cCtbaCp1 + "_SIGLA")[1])))

	While &(cCtbaTb1)->(!Eof()) .And. &(cCtbaTb1 + "->(" + cCtbaCp1 + "_FILIAL + " + cCtbaCp1 + "_SIGLA)") == xFilial(cCtbaTb1) + Padr(cSigla, TamSX3(cCtbaCp1 + "_SIGLA")[1])

		If Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_CONDIC"))

			nRecNull := &(cCtbaTb1)->(Recno())						

		ElseIf &(&(cCtbaTb1 + "->" + cCtbaCp1 + "_CONDIC"))

			nRecFull := &(cCtbaTb1)->(Recno())
			
			Exit

		EndIf

		&(cCtbaTb1)->(DbSkip()) 				  

	EndDo

	If nRecFull != 0

		&(cCtbaTb1)->(DbGoTo(nRecFull))

	ElseIf nRecNull != 0

		&(cCtbaTb1)->(DbGoTo(nRecNull))

	EndIf		
	
	If nRecFull != 0 .Or. nRecNull != 0
		
		&(cCtbaTb2)->(DbSetOrder(1))
		
		Do Case
								
			Case cTipo == "D"
							
				If &(cCtbaTb2)->(MsSeek(xFilial(cCtbaTb2) + &(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTDEB")))
												
					cRetorno := If(Empty(&( &(cCtbaTb2 + "->" + cCtbaCp2 + "_RETORN") )), &(cCtbaTb2 + "->" + cCtbaCp2 + "_CONTA"), &( &(cCtbaTb2 + "->" + cCtbaCp2 + "_RETORN") ))
													
				EndIf
												
			Case cTipo == "C"
			
				If &(cCtbaTb2)->(MsSeek(xFilial(cCtbaTb2) + &(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTCRE")))
						
					cRetorno := If(Empty(&( &(cCtbaTb2 + "->" + cCtbaCp2 + "_RETORN") )), &(cCtbaTb2 + "->" + cCtbaCp2 + "CONTA"), &( &(cCtbaTb2 + "->" + cCtbaCp2 + "_RETORN") ))
													
				EndIf
						
			Case cTipo == "H"
			
				cRetorno := &( &(cCtbaTb1 + "->" + cCtbaCp1 + "_HISTOR") )
						
			Case cTipo == "V"
			
				If cPartida  == "3"
				 
					cRetorno := If(!(Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTDEB"))) .And. !(Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTCRE"))), &(&(cCtbaTb1 + "->" + cCtbaCp1 + "_VALOR")), 0)
				
				ElseIf cPartida == "2"
				
					cRetorno := If( (Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTDEB"))) .And. !(Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTCRE"))), &(&(cCtbaTb1 + "->" + cCtbaCp1 + "_VALOR")), 0)
				
				ElseIf cPartida == "1" 
				
					cRetorno := If(!(Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTDEB"))) .And.  (Empty(&(cCtbaTb1 + "->" + cCtbaCp1 + "_ENTCRE"))), &(&(cCtbaTb1 + "->" + cCtbaCp1 + "_VALOR")), 0)
					
				Else
				
					cRetorno := 0		 

				EndIf
										
		End Do		
	
	EndIf
	
	If Empty(cRetorno)
	
		Do Case		
		
			Case cTipo == "D"; cRetorno := "SEM CONTA REGRA " + cSigla
			Case cTipo == "C"; cRetorno := "SEM CONTA REGRA " + cSigla
			Case cTipo == "H"; cRetorno := "SEM HISTORICO "   + cSigla			
			Case cTipo == "V"; cRetorno := 0
						
		End Do
		
	EndIf

Return cRetorno

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOGEN   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Retorna conta conforme regra genérica                         |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOGEN(cSigla, cTipo)

	Local cCtbaTb4 := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "4"
	Local cCtbaCp4 := If(SubStr(cCtbaTb4, 1, 1) == "S", SubStr(AllTrim(cCtbaTb4),2,2), AllTrim(cCtbaTb4))	
	Local cCtbaTb5 := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "5"
	Local cCtbaCp5 := If(SubStr(cCtbaTb5, 1, 1) == "S", SubStr(AllTrim(cCtbaTb5),2,2), AllTrim(cCtbaTb5))	
	Local cRetorno := ""
	Local nRecFull := 0
	Local nRecNull := 0
	Local aAreaAnt := Nil
		
	Default cSigla    := ""
	Default cTipo     := ""
		
	&(cCtbaTb4)->(DbSetOrder(1))	
	&(cCtbaTb5)->(DbSetOrder(1))
	
	&(cCtbaTb4)->(MsSeek(xFilial(cCtbaTb4) + Padr(cSigla, TamSX3(cCtbaCp4 + "_SIGLA")[1])))

	While &(cCtbaTb4)->(!Eof()) .And. &(cCtbaTb4 + "->(" + cCtbaCp4 + "_FILIAL + " + cCtbaCp4 + "_SIGLA)") == xFilial(cCtbaTb4) + Padr(cSigla, TamSX3(cCtbaCp4 + "_SIGLA")[1])

		If &(cCtbaTb5)->(MsSeek(xFilial(cCtbaTb5) + &(cCtbaTb4 + "->(" + cCtbaCp4 + "_SIGLA + " + cCtbaCp4 + "_SEQUEN)")))
		
			lCondicao := .T.
			
			While &(cCtbaTb5 + "->(" + cCtbaCp5 + "_FILIAL + " + cCtbaCp5 + "_SIGLA + " + cCtbaCp5 + "_SEQUEN)" ) == xFilial(cCtbaTb5) + &(cCtbaTb4 + "->(" + cCtbaCp4 + "_SIGLA + " + cCtbaCp4 + "_SEQUEN)")
						
				If !&( &(cCtbaTb5 + "->" + cCtbaCp5 + "_CONDIC") )
									
					lCondicao := .F.
										
				EndIf				
								
				&(cCtbaTb5)->(DbSkip())
			
			EndDo
			
			If lCondicao
	
				nRecFull := &(cCtbaTb4)->(Recno())						
	
				Exit
			
			EndIf
			
		Else
		
			nRecNull := &(cCtbaTb4)->(Recno())						
			
		EndIf
		
		&(cCtbaTb4)->(DbSkip()) 				  

	EndDo

	If nRecFull != 0

		&(cCtbaTb4)->(DbGoTo(nRecFull))

	ElseIf nRecNull != 0

		&(cCtbaTb4)->(DbGoTo(nRecNull))

	EndIf		
	
	If nRecFull != 0 .Or. nRecNull != 0
		
		&(cCtbaTb4)->(DbSetOrder(1))
		
		Do Case
								
			Case cTipo == "D"; cRetorno := &( &(cCtbaTb4 + "->" + cCtbaCp4 + "_DEBITO") )
			Case cTipo == "C"; cRetorno := &( &(cCtbaTb4 + "->" + cCtbaCp4 + "_CREDIT") )
			Case cTipo == "H"; cRetorno := &( &(cCtbaTb4 + "->" + cCtbaCp4 + "_HISTOR") )					
			Case cTipo == "O"; cRetorno := &( &(cCtbaTb4 + "->" + cCtbaCp4 + "_ORIGEM") )			
			Case cTipo == "V"; cRetorno := &( &(cCtbaTb4 + "->" + cCtbaCp4 + "_VALOR") )
														
		End Do		
	
	EndIf
	
	If Empty(cRetorno)
	
		Do Case		
		
			Case cTipo == "D"; cRetorno := "SEM CONTA REGRA " + cSigla
			Case cTipo == "C"; cRetorno := "SEM CONTA REGRA " + cSigla
			Case cTipo == "H"; cRetorno := "SEM HISTORICO "   + cSigla			
			Case cTipo == "O"; cRetorno := "REGRA GENERICA "  + cSigla   
			Case cTipo == "V"; cRetorno := 0
						
		End Do
		
	EndIf

Return cRetorno

/*---------+----------+-------+-----------------------+------+------------+
|Função    |Encontre  | Autor |Kenny Roger Martins    | Data | 22.12.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Função posicione com restarea.                                |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function Encontre(cAlias, nIndice, cChave, cCampo)

	Local cRet     := Nil
	Local aAreaAnt := (&(cAlias))->(GetArea())

	//Ticket https://totvsleste.freshdesk.com/a/tickets/2645 
	//Na rotina de cheque o sistema não estava encontrando o cheque.
	(&(cAlias))->(DbCloseArea())
	(&(cAlias))->(DbSetOrder(nIndice))
	(&(cAlias))->(DbGoTop())

	cRet := Posicione(cAlias, nIndice, cChave, cCampo)
	
	RestArea(aAreaAnt)

Return cRet

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOCLA   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastra a classe de valor(CTBA060) e retorna o código        |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOCLA(cCodigo,cIdentfi)

	Local cTipo     := Space(1)
	Local cNome     := ""
	Local cBloque   := ""
	Local cCGCcol   := ""
	Local cTipoNor  := "E"
	Local cDadosPos := ""
	Local aArea 	:= GetArea()
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaSA2  := SA2->(GetArea())
	Local cErro 	:= ""

	Default cCodigo  := Space(1)
	Default cIdentfi := ""

	IF FunName() == "CTBA080"
		Return ""
	Endif

	cTipo := SubStr(cCodigo, 1, 1)

	//Pegando o codigo do cliente
	cDadosPos := SubStr(cCodigo, 2, len(cCodigo))

	If !Empty(cTipo)
		//Cliente
		if(cTipo == "C")

			If SA1->(Dbseek(xFilial("SA1")+cDadosPos))		
				cTipoNor :=  "2"
				cNome 	 :=  SA1->A1_NOME
				cBloque  :=  SA1->A1_MSBLQL
				cCGCcol  :=  SA1->A1_CGC
			EndIf

		//Fornecedor
		elseIf SA2->(Dbseek(xFilial("SA2")+cDadosPos))
				cTipoNor :=  "1"
				cNome 	 :=  SA2->A2_NOME
				cBloque  :=  SA2->A2_MSBLQL
				cCGCcol  :=  SA2->A2_CGC
		EndIf

		CTH->(DbSetOrder(1))
				
		CTH->(RecLock("CTH", If(CTH->(MsSeek(xFilial("CTH") + cCodigo)), .F., .T.)))

		//Erro intermitente. Não conseguimos reproduzir. Aparentemente parece que existe uma outra customização. 
		//https://totvsleste.freshdesk.com/a/tickets/5528
		iF "E" $ cTipoNor

			cErro := "Erro, favor verificar "
			cErro += "o ponto de lançamento: " + CT5->CT5_LANPAD

			IF !EMPTY( cIdentfi )
				cErro += "Identificador : " + cIdentfi
			EndIF

			if empty(cCodigo)
				cErro += " que esta chamando a função AUTOCLA com o valor de codigo + loja vazio " +cCodigo
			Else
				cErro += " que esta chamando a função AUTOCLA com dodigo + loja com os seguintes valores " + cCodigo
			EndIF
			
			MsgStop(cErro)
		
		EndIF
				
		CTH->CTH_FILIAL		:= xFilial("CTH")
		CTH->CTH_CLVL		:= cCodigo
		CTH->CTH_CLASSE		:= "2"
		CTH->CTH_NORMAL 	:= cTipoNor
		CTH->CTH_DESC01		:= cNome
		CTH->CTH_BLOQ		:= cBloque
		CTH->CTH_YCGC    	:= cCGCcol
		CTH->CTH_DTEXIS 	:= CTOD("01/01/80")
		CTH->CTH_CLVLLP 	:= cCodigo
		CTH->CTH_CLSUP  	:= cTipo
	
		CTH->(MsUnLock())
	
	EndIf

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)


Return cCodigo


/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOITE   | Autor |Pedro Luiz    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cadastra a item de valor(CTBA040) e retorna o código  	  	  |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOITE(cCodigo,cIdentfi)

	Local cTipo     := Space(1)
	Local cNome     := ""
	Local cBloque   := ""
	Local cCGCcol   := ""
	Local cTipoNor  := "E"
	Local cDadosPos := ""
	Local aArea 	:= GetArea()
	Local aAreaSA1  := SA1->(GetArea())
	Local aAreaSA2  := SA2->(GetArea())
	Local cErro 	:= ""

	Default cCodigo  := Space(1)
	Default cIdentfi := ""

	cTipo := SubStr(cCodigo, 1, 1)

	//Pegando o codigo do cliente
	cDadosPos := SubStr(cCodigo, 2, len(cCodigo))

	If !Empty(cTipo)
		//Cliente
		if(cTipo == "C")

			If SA1->(Dbseek(xFilial("SA1")+cDadosPos))		
				cTipoNor :=  "2"
				cNome 	 :=  SA1->A1_NOME
				cBloque  :=  SA1->A1_MSBLQL
				cCGCcol  :=  SA1->A1_CGC
			EndIf

		//Fornecedor
		elseIf SA2->(Dbseek(xFilial("SA2")+cDadosPos))
				cTipoNor :=  "1"
				cNome 	 :=  SA2->A2_NOME
				cBloque  :=  SA2->A2_MSBLQL
				cCGCcol  :=  SA2->A2_CGC
		EndIf

		CTD->(DbSetOrder(1))
				
		CTD->(RecLock("CTD", If(CTD->(MsSeek(xFilial("CTD") + cCodigo)), .F., .T.)))

		//Erro intermitente. Não conseguimos reproduzir. Aparentemente parece que existe uma outra customização. 
		//https://totvsleste.freshdesk.com/a/tickets/5528
		iF "E" $ cTipoNor

			cErro := "Erro, favor verificar "
			cErro += "o ponto de lançamento: " + CT5->CT5_LANPAD

			IF !EMPTY( cIdentfi )
				cErro += "Identificador : " + cIdentfi
			EndIF

			if empty(cCodigo)
				cErro += " que esta chamando a função AUTOITE com o valor de codigo + loja vazio " +cCodigo
			Else
				cErro += " que esta chamando a função AUTOITE com dodigo + loja com os seguintes valores " + cCodigo
			EndIF
			
			MsgStop(cErro)
		
		EndIF
				
		CTD->CTD_FILIAL	:= xFilial("CTD")
		CTD->CTD_ITEM	:= cCodigo
		CTD->CTD_CLASSE	:= "2"
		CTD->CTD_NORMAL	:= cTipoNor
		CTD->CTD_DESC01	:= cNome
		CTD->CTD_BLOQ	:= cBloque
		CTD->CTD_YCGC   := cCGCcol
		CTD->CTD_DTEXIS	:= CTOD("01/01/80")
		CTD->CTD_ITLP	:= cCodigo
		CTD->CTD_ITSUP 	:= cTipo
	
		CTD->(MsUnLock())
	
	EndIf

	RestArea(aArea)
	RestArea(aAreaSA1)
	RestArea(aAreaSA2)


Return cCodigo

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOENT   | Autor |Kenny Roger Martins    | Data | 08.06.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Retorna conta padrão do cadastro de entidade padrão.          |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOENT(cCodigo)

	Local cCtbaTb2 := AllTrim(GetMv("ZY_CTBATAB", .F., "")) + "2"
	Local cCtbaCp2 := If(SubStr(cCtbaTb2, 1, 1) == "S", SubStr(AllTrim(cCtbaTb2),2,2), AllTrim(cCtbaTb2))	
	Local cConta   := "SEM CONTA PADRAO"
	
	Default cCodigo := Space(20)	
		
	&(cCtbaTb2)->(DbSetOrder(1))
	
	If &(cCtbaTb2)->(MsSeek(xFilial(cCtbaTb2) + cCodigo))
			
		cConta := &(&(cCtbaTb2 + "->" + cCtbaCp2 + "_RETORN"))

		If Empty(cConta)

			cConta := &(cCtbaTb2 + "->" + cCtbaCp2 + "_CONTA")
		
		EndIf
	
	EndIf
	
Return cConta

/*---------+----------+-------+-----------------------+------+------------+
|Função    |AUTOVAL   | Autor |Kenny Roger Martins    | Data | 08.03.2017 |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Retorna o valor conforme a regra genérica.                    |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/
User Function AUTOVAL(cVariavel, cTipo)

	Local lRetorno := .T.
	Local aRetSyntax := {}
	Local bBlock := Nil
	
	Default cVariavel := ""
	Default cTipo := "C/N"
	
	If "$" $ cVariavel .Or. "==" $ cVariavel .Or. "<>" $ cVariavel .Or. "!=" $ cVariavel
	
		cVariavel := "IF(" + cVariavel + ",'','')"
		
	EndIf
	
	aRetSyntax := ParAnalise( cVariavel )	// Análise estrutural de sintaxe
		
	IF !Empty( aRetSyntax[1] )
			
		Help( " ", 1, "ERR_FORM", , OemToAnsi( "Estrutura Inconsistente : " + aRetSyntax[1] ), 3, 0) // Estrutura Inconsistente :
		 		
		lRetorno := .F.
				
	Else
		
		bBlock := ErrorBlock( { |e| ChecErro(e) } )
		
		BEGIN SEQUENCE
		
			cVariavel := &cVariavel
					
			If ValType(cVariavel) $ cTipo
						
				lRetorno := .T.
								
			Else
						
				lRetorno := .F.
							
			EndIf
							
		RECOVER
				
			lRetorno := .F.
						
		END SEQUENCE
		
		ErrorBlock(bBlock)		
	EndIf
	
Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ParAnalise³ Autor ³ J£lio Wittwer         ³ Data ³ 17.12.99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza an lise estrutural de parƒmetros / delimitadores   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ParAnalise(cExpressao)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Vetor [1] cStack -> Se preenchido, indica qual caracter na ³±±
±±³          ³ estrutura n„o est  coerente com a mesma.                   ³±±
±±³          ³ Vetor [2] aParam -> Array com os textos correspondentes    ³±±
±±³          ³ dentro das estruturas.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA080                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ expC1 = Texto a ser analisado.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ParAnalise(cTexto)
Local cStack:=""  , cAspas:=""
Local aSepFunc:={"()","[]","{}"}, aParam:={}
Local nPosAt:=1 , uLastPar:=1 , cPosAtual
Local uAbre , uFecha , cSeparador:=","
// Arranca os caracteres da esquerda se forem 'espa‡o' ou 'TAB'
While left(cTexto,1)==" " .or. left(cTexto,1)==chr(9)
   cTexto:=right(cTexto,len(cTexto)-1)
EndDo
While nPosAt<=len(cTexto)
   cPosAtual:=substr(cTexto,nPosAt,1)
   If cPosAtual==chr(34) .or. cPosAtual==chr(39)	// Achou "ASPAS"
		cAspas:=If(empty(cAspas),cPosAtual,If(cAspas == cPosAtual,"",cAspas))
   Endif
   If empty(cAspas)			// Apenas analiza a estrutura caso nao esteja entre aspas
      uAbre :=ascan(aSepFunc,{|_v|  left(_v,1) == cPosAtual})
      uFecha:=ascan(aSepFunc,{|_v| right(_v,1) == cPosAtual})
      If uAbre+uFecha>0		// Abriu ou Fechou uma estrutura
         If uAbre>0	// Abriu uma estrutura ! Acrescenta no STACK
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1	 ; cStack:=cStack+cPosAtual
         Else			// Fechou uma estrutura : Checa o STACK
            If right(cStack,1)==Left(aSepFunc[uFecha],1)	// Se fechou certo, tira do Stack
               cStack:=left(cStack,len(cStack)-1)
				Else	// Estrutura fechada incorretamente
					cStack:=right(aSepFunc[uFecha],1)
					EXIT
            Endif
            If !empty(substr(cTexto,uLastPar,nPosAt-uLastPar))
               aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            Endif
	         uLastPar:=nPosAt+1
         Endif
      Else	// Verifica separador
			If cPosAtual==cSeparador
            aadd(aParam,substr(cTexto,uLastPar,nPosAt-uLastPar))
            uLastPar:=nPosAt+1
         Endif
      Endif
   Endif
	nPosAt++
EndDo
IF !empty(cTexto) .and. len(aParam) == 0
	aadd(aParam,alltrim(cTexto))
Endif
cStack+=if(empty(cAspas),"",cAspas)
Return {cStack,aParam}
