--URL Unicode conversation

DEFINE UrlDecode InvokeForString('java.net.URLDecoder.decode', 'String String');

--Importing Source file

Source_file = LOAD '/SrcFile' using PigStorage(',','-tagFile') as (ipAddr:chararray, id:int, lastvisitedtime:chararray, title:chararray, typedcount:int, URL:chararray, visitcount:int, bytes:int);

--Removing the special character (T) from Time field

	Cleanse_1= FOREACH Source_file GENERATE id, ipAddr, SUBSTRING(REPLACE(lastvisitedtime,'T',' '),0,19) as  lastvisitedtime,title,typedcount,URL,visitcount,bytes; 

--Spliting the domain (www.google.com) from URL

	Domain = FOREACH Cleanse_1 GENERATE id, ipAddr, URL, lastvisitedtime ,bytes, SUBSTRING(URL,INDEXOF(URL,'://')+3,INDEXOF(URL,'/',8));

--Spliting the parameters from URL

Search_logs = FOREACH Cleanse_1 GENERATE id, ipAddr, URL,lastvisitedtime ,bytes, SUBSTRING(URL,INDEXOF(URL,'?',8), CASE INDEXOF(URL,'#') WHEN -1 THEN (INT) SIZE(URL) ELSE INDEXOF(URL,'#') END ),title;

--Extracting the Searched words from above splitted parameters. Below parameters are analysed based on the top 10 search engines.

-- Finding the text starting search keyword

Keyword_index = FOREACH Search_logs GENERATE $0,$1,$2,$3,$4,$5, CASE WHEN INDEXOF($5,'?q=')!=-1 THEN INDEXOF($5,'?q=')+2 
 WHEN INDEXOF($5,'?p=')!=-1 THEN INDEXOF($5,'?p=')+2  
 WHEN INDEXOF($5,'?wd=')!=-1 THEN INDEXOF($5,'?wd=')+3
 WHEN INDEXOF($5,'?text=')!=-1 THEN INDEXOF($5,'?text=')+5
 WHEN INDEXOF($5,'?search_query=')!=-1 THEN INDEXOF($5,'?search_query=')+13
 WHEN INDEXOF($5,'?field-keywords=')!=-1 THEN INDEXOF($5,'?field-keywords=')+15
 WHEN INDEXOF($5,'?keywords=')!=-1 THEN INDEXOF($5,'?keywords=')+9
 WHEN INDEXOF($5,'&q=')!=-1 THEN INDEXOF($5,'&q=')+2 
 WHEN INDEXOF($5,'&p=')!=-1 THEN INDEXOF($5,'&p=')+2 
 WHEN INDEXOF($5,'&wd=')!=-1 THEN INDEXOF($5,'&wd=')+3
 WHEN INDEXOF($5,'&text=')!=-1 THEN INDEXOF($5,'&text=')+5
 WHEN INDEXOF($5,'&search_query=')!=-1 THEN INDEXOF($5,'&search_query=')+13
 WHEN INDEXOF($5,'&field-keywords=')!=-1 THEN INDEXOF($5,'&field-keywords=')+15
 WHEN INDEXOF($5,'&keywords=')!=-1 THEN INDEXOF($5,'&keywords=')+9
END,title;

-- Extracting the text search keyword

Searched_words = FOREACH Keyword_index GENERATE $0,$1,$2,$3,$4,SUBSTRING($5,$6+1,CASE INDEXOF($5,'&',$6) WHEN -1 THEN (INT) SIZE($5) ELSE INDEXOF($5,'&',$6) END),title;

Keywords = FOREACH Searched_words GENERATE $0,$1,$2,$3,$4, CASE WHEN (int) SIZE((chararray) $5) > 0  THEN $5 ELSE title END as keyword;

-- Removing the empty search keywords records

Cleansed_words = FILTER Keywords BY (int) SIZE((chararray) $5) > 1;

-- Convert the Unicode to decode values (Proper symbols)

word = FOREACH Cleansed_words GENERATE $0,$1,$2,$3,$4,UrlDecode($5, 'UTF-8');

-- Exploiting to words from sentence

keyword = FOREACH word GENERATE $0,$1,$2,$3,$4,5, FLATTEN(STRSPLITTOBAG($5,' |\\u002B'));

-- Extracting the Pages from URL

Pages = FOREACH Cleanse_1 GENERATE id, ipAddr, URL,lastvisitedtime ,bytes, SUBSTRING(URL,INDEXOF(URL,'/',8), CASE WHEN INDEXOF(URL,'.php') !=-1 THEN INDEXOF(URL,'.php') WHEN INDEXOF(URL,'.htm') !=-1 THEN INDEXOF(URL,'.htm') WHEN INDEXOF(URL,'.asp') !=-1 THEN INDEXOF(URL,'.asp') WHEN INDEXOF(URL,'?') !=-1 THEN INDEXOF(URL,'?') WHEN INDEXOF(URL,'#') !=-1 THEN INDEXOF(URL,'#') ELSE (INT) SIZE(URL) END );


-- Exploiting to words from sentence for Pages

Page = FOREACH Pages GENERATE $0,$1,$2,$3,$4,2, FLATTEN(STRSPLITTOBAG($5,'%|-|~|_|/+|//'));


-- Removing the empty search keywords records

Fil_page = FILTER Page BY (int) SIZE((chararray) $6) > 2 AND (int) SIZE((chararray) $6) < 16;

-- Combining the Page result & Searched words

Combine_Keywords = UNION keyword, Fil_page;

Final_Keywords = FILTER Combine_Keywords BY (int) SIZE((chararray) $6) > 2 AND (int) SIZE((chararray) $6) < 16;

-- Exporting to output file

STORE Domain into '/DOMAIN' using PigStorage(',');

STORE word into '/WORDS' using PigStorage(',');

STORE Final_Keywords into '/KEYWORDS' using PigStorage(',');

