#INCLUDE 'PROTHEUS.CH'

/*---------+----------+-------+-----------------------+------+------------+
|Função    |CTBAZ09   | Autor |Pedro Luiz f lima       | Data | 28.02.2024|
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Exporta dados de Clientes e Fornecedores para a tabela CTD    |
+----------+--------------------------------------------------------------+
|Uso       |GR+                                                           |
+----------+-------------------------------------------------------------*/

User Function CTBAZ09()

	Private oProcess

	If MsgYesNo("Deseja realmente exportar os dados de clientes/fornecedores para a tabela CTD?","Alerta")
		oProcess := MsNewProcess():New({|lEnd| fExportCTD()})
		oProcess:Activate()
	EndIf

Return()


Static Function fExportCTD()

	ExportSA1()
	ExportSA2()
	
Return(.T.)


// Exporta Clientes

Static Function ExportSA1()

	Local aAreaSA1 := SA1->(GetArea())
	Local aAreaCTD := CTD->(GetArea())
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbGoTop()
	
	oProcess:SetRegua1(SA1->(RecCount()))
	oProcess:SetRegua1(SA1->(RecCount()))
	
	oProcess:IncRegua1("Exportando dados de clientes...")
	
	While !SA1->(EOF())
		
		oProcess:IncRegua1("Exportando dados de clientes...")
		
		DbSelectArea("CTD")
		CTD->(DbSetOrder(1))
		
		If !(CTD->(DbSeek(xfilial("CTD")+"C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA))))
			
			oProcess:IncRegua2("Cliente: " + ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)+ " - " + AllTrim(SA1->A1_NOME))
			
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xfilial("CTD")
			CTD->CTD_ITEM		:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
			CTD->CTD_CLASSE		:= "2"
			CTD->CTD_NORMAL		:= "2"
			CTD->CTD_DESC01		:= SA1->A1_NOME
			CTD->CTD_BLOQ		:= "2"
			CTD->CTD_YCGC    	:= SA1->A1_CGC // FILTRO NA CLASSE DE VALOR POR CNPJ
			CTD->CTD_DTEXIS 	:= CTOD("01/01/80") 
			CTD->CTD_ITLP	 	:= "C"+ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)
			CTD->CTD_ITSUP  	:= 'C'
			CTD->(MsUnLock())
			
		EndIf
		
		oProcess:IncRegua2("Cliente: " + ALLTRIM(SA1->A1_COD)+ALLTRIM(SA1->A1_LOJA)+ " - " + AllTrim(SA1->A1_NOME))
		
		SA1->(DbSkip())
		
	EndDo
	
	oProcess:IncRegua2("")
	oProcess:IncRegua1("Exportação de clientes concluida...")
	
	RestArea(aAreaSA1)
	RestArea(aAreaCTD)

Return()


// Exporta Fornecedores

Static Function ExportSA2()

	Local aAreaSA2 := SA2->(GetArea())
	Local aAreaCTD := CTD->(GetArea())
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbGoTop()
	
	oProcess:SetRegua1(SA2->(RecCount()))
	oProcess:SetRegua2(SA2->(RecCount()))
	
	oProcess:IncRegua1("Exportando dados de fornecedores...")
	
	While !SA2->(EOF())
		
		oProcess:IncRegua1("Exportando dados de fornecedores...")
		
		DbSelectArea("CTD")
		CTD->(DbSetOrder(1))
		
		If !(CTD->(DbSeek(xFilial("CTD")+"F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA))))
			
			oProcess:IncRegua2("Fornecedor: " + ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)+ " - " + AllTrim(SA2->A2_NOME))
			
			RecLock("CTD",.T.)
			CTD->CTD_FILIAL	:= xFilial("CTD")
			CTD->CTD_ITEM		:= "F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
			CTD->CTD_CLASSE	:= "2"
			CTD->CTD_NORMAL	:= "1"
			CTD->CTD_DESC01	:= SA2->A2_NOME
			CTD->CTD_BLOQ		:= "2"
			CTD->CTD_YCGC    	:= SA2->A2_CGC // FILTRO NA CLASSE DE VALOR POR CNPJ
			CTD->CTD_DTEXIS 	:= CTOD("01/01/80")
			CTD->CTD_ITLP 	:= "F"+ALLTRIM(SA2->A2_COD)+ALLTRIM(SA2->A2_LOJA)
			CTD->CTD_ITSUP  	:= 'F'
			CTD->(MsUnLock())
			
		EndIf
		
		SA2->(DbSkip())
	EndDo
	
	
	oProcess:IncRegua2("")
	oProcess:IncRegua1("Exportação de fornecedores concluida...")
	
	RestArea(aAreaSA2)
	RestArea(aAreaCTD)

Return()
