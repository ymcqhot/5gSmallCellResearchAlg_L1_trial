# 5gSmallCellResearchAlg_L1
			
5gSmallCellResearchAlg_L1
	|
	|
	|---Common
	|
	|
	|---DL
	|   |
	|	|
	|	|---DlTx
	|		|
	|		|
	|		|---Common
	|		|
	|		|
	|		|---CSIRS
	|		|
	|		|
	|		|---PDCCH					  
	|		|
	|		|
	|		|---PDSCH	
	|		|
	|		|
	|		|---SSB			
	|		|
	|		|
	|		|---Upper
	|    
	|    
	|---Doc
	|   | 
	|	|
	|	|---5gSmallCellResearchAlg_L1.pptx - Basic introduction and trial method 
	|   |
	|	|
	|	|---Feature list.xlsx		
	|   |
	|	|
	|	|---Interface.docx
	|   |
	|	|
	|	|---Test cases.xlsx	- in 5gSamllCellCase_L1/Doc			
	|   |
	|	|
	|	|---Version.txt					
	|
	|
	|---Template		
	|	|
	|	|
	|	|---channelTemplate	- Configuration of channel model
	|	|
	|	|
	|	|---frcTemplate	- Configuration of performance requirement in 38.104		
	|	|
	|	|
	|	|---systemTemplate - Configuration of system of performance requirement in 38.104
	|	   
	|	   
	|---Test	
	|	|
	|	|
	|	|---simDlRef - SystemVue project for generating reference of DL TX		
	|	|
	|	|
	|	|---simUlRef - SystemVue project for generating reference of UL TX			
	|	   
	|	   
	|---UL	
	|	|
	|	|
	|	|---UlRx	
	|	|   |
	|	|   |
	|	|	|---Channel
	|	|   |
	|	|   |
	|	|   |---Common
	|	|   |
	|	|   |
	|	|   |---PUCCH		
	|	|   |     
	|	|   |     
	|	|   |---PUSCH		
	|   |   |
	|   |   |					
	|	|   |---Upper								 
	|	| 
	|	| 
	|	|---UlTx						 
	|	    |
	|	    |
	|		|---Channel
	|	   	|
	|	   	|
	|	   	|---Common
	|	   	|
	|	   	|
	|	   	|---PUCCH		
	|	   	|     
	|	   	|     
	|	   	|---PUSCH		
	|       |
	|       |	   
	|	   	|---Upper
	|
	|
	|---Utils
		|
		|
		|---Compare - Tool for comparing between output and reference of TX 
		|
		|
		|---Figure - Tool for drawing figure of RX performance
		|
		|
		|---Read - Tool for reading		
		|     
		|     
		|---Reference - Tool for tranforming frequency data from timing data generated from SystemVue 		
		|      
		|     
		|---Write - Tool for writing		
			