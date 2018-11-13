# xmlDxSpider

Description:
-----------------------------------------------------------------------------------------
		XML Based Web Interface for DXSpider
		Juan J Lamas - EA1NK
		24 February 2014

Sample site: http://www.ed1zac.net/webdx/


1. Why XML Web Interface?

	The original DL5DI webcluster interface was only able to run in a local server, 
	with no option to retrieve the spots but including an <IFRAME> on a external web
	page or complicated parsing.

	Using the modified scripts to output a XML document, one can retrieve the spots
	with a simple HTTP Request in Javascript, PHP or any other programming language. 
	Not only for web display but also for webapps, native apps or any kind of software.


2. The XML document.

	The XML document is generated by webclusterXML.py Perl script. It is a populated list
	of spots, wcy, wwv and announces gathered from the files generated by DXSpider. More
	info on how it works can be found on DL5DI website. A sample.xml file is provided.

	The document can be retrieved on http://webserver_address/cgi-bin/webclusterXML

	The structure of the XML documents is:

	Header: <?xml version='1.0' encoding='UTF-8'?>
	
	Container for all the data: 	<DATA></DATA>
	Container for all the spots: 	<SPOTS></SPOTS>
	Single spot:					<SPOT></SPOT> 
	Spot information:
									<FROM></FROM>
									<QRG></QRG>
									<DX></DX>
									<TEXT></TEXT>
									<CQ></CQ>
									<PREFIX></PREFIX>
									<UTC></UTC>

	Container for all WCYs:			<WCYS></WCYS>
	Single WCY:						<WCY></WCY>
	WCY information:				
									<FROM></FROM>
									<DATE></DATE>
									<SFI></SFI>
									<A></A>
									<K></K>
									<expK></expK>
									<R></R>
									<SA></SA>
									<GMF></GMF>
									<AURORA></AURORA>
	
	Container for all WWV:			<WWVS></WWVS>
	Single WWV:						<WWV></WWV>
	WWV information:				
									<FROM></FROM>
									<DATE></DATE>
									<SFI></SFI>
									<A></A>
									<K></K>
									<TEXT></TEXT>

	Container for all announces:	<ANNS></ANNS>
	Single announce:				<ANN></ANN>
	Announce information:			
									<PATH></PATH>
									<DATE></DATE>
									<TEXT></TEXT>

3. The Web interface.

	The provided index.html file is a simple layout made in HTML5 and Javascript. The XML 
	document is gathered via a HTTPRequest and parsed in Javascript. The tables are 
	dinamically populated with the data in the XML file.
	
	No special features are required on the server side for the interface to run. Any 
	modern web browser (> Internet Explorer 6, Chrome, Firefox, Safari) or device
	(iOS, Android) should render the interface correctly.

	All the style info is attached in the css files, so it is easy to modify.  
	
	Data is gathered from the DXSpider server every 30 seconds.

4. Installation.

	Perl and Bash scripts:
		
		Copy webclusterXML to /usr/lib/cgi-bin directory or your cgi-bin path.
        Copy webclusterXML.pl to /usr/local/bin directory or your bin path.
		Edit webclusterXML to point to webclusterXML.pl if not in default path.

	HTML interface
		
		Copy htmldocs content to the desired directory on the webserver.  


73!                                               
