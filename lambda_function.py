import requests
import json
from bs4 import BeautifulSoup
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

# ISBN값을 가져와서 도서관 홈페이지의 완전일치검색 페이지로 요청하는 URL생성하는 함수.
def GetURL1(isbn, school):
	if school is 1:
		return 'https://library.sogang.ac.kr/search/tot/result?st=EXCT&si=6&q='+isbn
	elif school is 2:
		return 'https://library.yonsei.ac.kr/search/tot/result?st=EXCT&si=6&q='+isbn+'&folder_id=null&lmt0=YNLIB;GSISL;MUSEL;OTHER;UGSTL;YSLIB;ARCHL;BUSIL;KORCL;IOKSL;LAWSL;MULTL;MATHL;MUSIC&lmtsn=000000000006&lmtst=OR#'
	elif school is 3:
		return 'https://lib.ewha.ac.kr/search/tot/result?st=KWRD&si=TOTAL&service_type=brief&q='+isbn
	elif school is 4:
		return 'https://honors.hongik.ac.kr/search/tot/result?st=EXCT&si=6&q='+isbn


# GETURL1함수에서 생성한 url로부터, 도서의 상세대출정보를 담고 있는 상세페이지 요청을 위한 파라미터값을 긁어오는 함수
def GetDetail(url, school):
	resp=requests.get(url, verify=False)
	html=resp.text
	soup=BeautifulSoup(html, 'html.parser')

	if school is 1 or school is 4:
		detail=soup.find("dd", "searchTitle")
	elif school is 2 or school is 3:
		detail=soup.find("dd", "book")

	if detail is None:
		return detail
	
	detail=detail.find("a").get('href')
	return detail
  
  
# 도서의 상세대출정보를 담고 있는 상세페이지로의 요청 url을 생성하는 함수 - GetDetail(url,school)에서 가져온 파라미터값을 이용한다.
def GetURL2(detail, school):
	if school is 1:
		return 'https://library.sogang.ac.kr'+detail
	elif school is 2:
		return 'https://library.yonsei.ac.kr'+detail
	elif school is 3:
		return 'https://lib.ewha.ac.kr'+detail
	elif school is 4:
		return 'https://honors.hongik.ac.kr'+detail	
        
        
# 도서관의 도서상세정보페이지로부터 얻고자 하는 도서대출정보들을 파싱하는 함수.
def GetLibInfo(url, school):
	#print("school : %s" %school)
	resp=requests.get(url, verify=False)
	html=resp.text
	soup=BeautifulSoup(html, 'html.parser')
	tr=soup.find_all("tbody")[1].find_all("tr")

	books=[]
	for row in tr:
		td=row.find_all("td")
		book=GetOneBook(td, school)#대출정보를 담고 있는 테이블로부터 한 권 씩 정보를 가져온다.
		if book is not None: books.append(book)
	return books

#대출정보를 담고 있는 테이블로부터 한 권 씩 정보를 가져오는 함수
def GetOneBook(td, school):
	temp=[]
	for i in range(8):
		if school is 3 and (i is 5 or i is 6): continue
		elif i is 6: break
		item=td[i].text.strip()
		item=item.replace("\t", "")
		item=item.replace("\n", "")
		item=item.replace("\r", "")
		temp.append(item)
	book=DataTrim(temp, school)
	return book

# JSON 데이터 전송을 위해 크롤링한 데이터를 딕셔너리 형태로 가공해주는 함수
def DataTrim(temp, school):
	if school is 1:
		book={'no': temp[0], 'location': temp[1], 'callno': temp[2], 'id': temp[3], 'status': temp[4], 'returndate': temp[5]}

	elif school is 2:
		if '국' in temp[3][1]: return None
		book={'no': temp[0], 'id': temp[1], 'callno': temp[2], 'location': temp[3], 'status': temp[4], 'returndate': temp[5]}

	elif school is 3:
		book={'no': temp[0], 'location': temp[1], 'callno': temp[2], 'status': temp[3], 'returndate': temp[4], 'id': temp[5]}
		
	elif school is 4:
		if '문' in temp[3][0]: return None
		book={'no': temp[0], 'id': temp[1], 'callno': temp[2], 'location': temp[3], 'status': temp[4], 'returndate': temp[5]}

	return book
		

# AWS Lambda 핸들러
def lambda_handler(event, context):
	isbn=event['isbn']
	libinfo={}

	for i in range(1,5):
		url=GetURL1(isbn, i)
		detail=GetDetail(url, i)
		contents={}
		if detail is None:
			books=[]
			contents['books']=books
			contents['url']=""
			if i is 1: libinfo['sogang']=contents
			elif i is 2: libinfo['yonsei']=contents
			elif i is 3: libinfo['ewha']=contents
			elif i is 4: libinfo['hongik']=contents
			continue
		url=GetURL2(detail, i)
		books=GetLibInfo(url, i)
		contents['books']=books
		contents['url']=url

		if i is 1: libinfo['sogang']=contents
		elif i is 2: libinfo['yonsei']=contents
		elif i is 3: libinfo['ewha']=contents
		elif i is 4: libinfo['hongik']=contents
	
	return libinfo
