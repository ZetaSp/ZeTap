" ZeTap - THE Translation Auto Processor
" Maintainer:	Zetaspace <ideaploter@outlook.com>
" Version:	0.3.1 Alpha
" Last Update:	2021 Jun 10



let ZeTap_Version='0.3.1'
let DEBUG=0
let AUTOMAKE=0
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set nofixeol



""" DEBUG
function! DEBUG(info)
	if g:DEBUG==1
		echo '[DEBUGINFO] '.a:info
	endif
endfunction
command! -nargs=1 -bar DEBUG call DEBUG(<args>)



""" While True Break
let g:True=1
function! True()
	if g:True==0
		let g:True=1
		return 0
	else
		return 1
	endif
endfunction
function! Break()
	let g:True=0
endfunction
command! -nargs=0 -bar Break call Break()
command! -nargs=0 -bar True call True()
"nmap echo :echo "True is ".True."."<enter>	"Test only.
" while True()
" 	<COMMANDS>
" 	Break
" endwhile



""" Goto
let g:GotoDict={'SOF':0, 'EOF':-1}
let g:RunPointer=-1 "Not running.
function! To(lable)
	if g:RunPointer>=0
		let g:GotoDict[a:lable]=g:RunPointer
	else
		echo '[error] Out of the virtual machine.'
	endif
endfunction
function! Goto(lable)
	if g:RunPointer>=0
		if has_key(g:GotoDict,a:lable)
			let g:NextRunPointer=g:GotoDict[a:lable]
		else
			echo '[error] Lable '''.a:lable.''' not found.'
		endif
	else
		echo '[error] Out of the virtual machine.'
	endif
endfunction
command! -nargs=1 -bar To call To(<args>)
command! -nargs=1 -bar Goto call Goto(<args>)
"
" To <LABLE>
"    Create: The LABLE
" Goto <LABLE>
"    JumpTo: It
"
" Available: 	INSIDE the virtual machine.
" Preproces:	'::' at code start will be pre-processed as LABLEs.
" 	e.g.	::LABLE1
" Overwrite: 	Always.



""" Run.Manager
let Run=[]
function! Runnew(data)
	let g:Run+=[[a:data.'']]
endfunction
function! Runarg(data)
	if len(g:Run)<1
		echo '[error] Run is empty. Please Runnew() first.'
	else
		let g:Run[len(g:Run)-1]+=[a:data.'']
	endif
endfunction
function! Runmore(data)
	if len(g:Run)<1
		echo '[error] Run is empty. Please Runnew() first.'
	else
		let g:Run[len(g:Run)-1][len(g:Run[len(g:Run)-1])-1].=a:data.''
	endif
endfunction
function! Run0more(data)
	if len(g:Run)<1
		echo '[error] Run is empty. Please Runnew() first.'
	else
		let g:Run[len(g:Run)-1][0].=a:data.''
	endif
endfunction
"nmap echo :echo Run<enter>		"Test only.
"nmap clean :let Run=[]<enter>		"Test only.



""" Edit Actions
function! CheckRange()
	if exists('b:Range')!=1
		DEBUG '检查边界: 不存在，默认全选'
		let b:Range=['','$']
	else
		DEBUG '检查边界: 存在'
	endif
endfunction
function! LocateIndex(r)
	let re=a:r[:]
	if re[0]is''
		let re[0]=[0,0]
	endif
	if re[1]is'$'
		let re[1]=[0,0]
	endif
	if re[0][0]==0
		let re[0][0]=1
	endif
	if re[0][1]==0
		let re[0][1]=1
	endif
	if re[1][0]==0
		let re[1][0]=line('$')
	endif
	if re[1][1]==0
		let re[1][1]=len(getline(line('$')))	" DO NOT USE col('$') HERE !!!
	endif
	let re[0][0]-=1
	let re[0][1]-=1
	let re[1][0]-=1
	let re[1][1]-=1
	DEBUG '索引边界: ['.re[0][0].','.re[0][1].'],['.re[1][0].','.re[1][1].']'
	return re
endfunction

function! Replace(a='',b='')
	DEBUG '替换: '.a:a.' --> '.a:b
	echo '□■ '.a:a.' --> '.a:b


	echo '0------------------------'
	echo '[DBG] fullpage'
	echo fullpage
	echo '[DBG] b:Range'
	echo b:Range
	echo '[DBG] pageL'
	echo pageL
	echo '[DBG] page'
	echo page
	echo '[DBG] pageR'
	echo pageR
	echo '[DBG] pagestrL'
	echo pagestrL
	echo '[DBG] pagestr'
	echo pagestr
	echo '[DBG] pagestrR'
	echo pagestrR
	echo '[DBG] pagestr0'
	echo pagestr0
	echo '[DBG] pagestr1'
	echo pagestr1
	echo '------------------------'


	call CheckRange()
	let i=LocateIndex(b:Range)
	let L0=i[0][0]
	let L1=i[0][1]
	let R0=i[1][0]
	let R1=i[1][1]

	" E X A M P L E
	"
	" Read
	"    fullpage (list)
	"       The quick brown fox jumps over the lazy dog.
	"       The quick brown <fox> jumps over the lazy dog.	<-- Selected line
	"       The quick brown fox jumps over the lazy dog.
	"
	" Separate
	"    pageL (--> str):
	"       The quick brown fox jumps over the lazy dog.
	"       The quick brown_
	"    page (--> str --> substitute):
	"       fox -> dog
	"    pageR (--> str):
	"       _jumps over the lazy dog.
	"
	" Unite
	"    str.str.str --> split("\n") --> list
	"       The...dog.\nThe quick brown_
	"       + dog
	"       + _jumps over...dog.\nThe...dog.
	"    ->	The quick brown fox jumps over the lazy dog.
	"    ->	The quick brown dog jumps over the lazy dog.
	"    ->	The quick brown fox jumps over the lazy dog.
	"
	" Write
	"    Delete all.
	"    Write pages.

	let pageL=[]
	let page=[]
	let pageR=[]
	let pagestrL=''
	let pagestr=''
	let pagestrR=''
	let fullpage=getline(1,'$')


	echo '1------------------------'
	echo '[DBG] fullpage'
	echo fullpage
	echo '[DBG] i'
	echo i
	echo '[DBG] pageL'
	echo pageL
	echo '[DBG] page'
	echo page
	echo '[DBG] pageR'
	echo pageR
	echo '[DBG] pagestrL'
	echo pagestrL
	echo '[DBG] pagestr'
	echo pagestr
	echo '[DBG] pagestrR'
	echo pagestrR
	echo '[DBG] pagestr0'
	echo pagestr0
	echo '[DBG] pagestr1'
	echo pagestr1
	echo '------------------------'


	if L0!=0				" If the former part line is not empty
		let pageL+=fullpage[:L0-1]
		let pageL+=['']			" The start of a new line (the selected line)
	endif
	let pageR+=fullpage[R0+1:]
	let pagestrL.=join(pageL,"\n")		" DO NOT USE += HERE !!!

	if L0==R0
		let page=fullpage[L0:R0]
		let pagestr=page[0]

		let pagestrR.=pagestr[R1+1:]
		let pagestr=pagestr[:R1]
		if L1!=0
			let pagestrL.=pagestr[:L1-1]
			let pagestr=pagestr[L1:]
		endif
	else
		let pagestr0=fullpage[L0]		" Selected line 0
		let pagestr1=fullpage[R0]		" Selected line 1
		let page=fullpage[L0+1:R0-1]		" Lines between two selected lines

		let pagestrR.=pagestr1[R1+1:]
		let pagestr1=pagestr1[:R1]
		if L1!=0
			let pagestrL.=pagestr0[:L1-1]
			let pagestr0=pagestr0[L1:]
		endif

		let pagestr=join([pagestr0]+page+[pagestr1],"\n")
	endif

	if pageR!=[]
		let pagestrR.="\n".join(pageR,"\n")
	endif


	echo '2------------------------'
	echo '[DBG] fullpage'
	echo fullpage
	echo '[DBG] i'
	echo i
	echo '[DBG] pageL'
	echo pageL
	echo '[DBG] page'
	echo page
	echo '[DBG] pageR'
	echo pageR
	echo '[DBG] pagestrL'
	echo pagestrL
	echo '[DBG] pagestr'
	echo pagestr
	echo '[DBG] pagestrR'
	echo pagestrR
	echo '[DBG] pagestr0'
	echo pagestr0
	echo '[DBG] pagestr1'
	echo pagestr1
	echo '------------------------'



	let pagestr=substitute(pagestr,a:a,a:b,'g')	" Substitute selected part
	let pagestr=pagestrL.pagestr.pagestrR		" Reunite
	let page=split(pagestr,"\n",1)
	1,$delete
	call setline(1,page)

	"let buf=bufnr()
	"call bufload(buf)
	"let page=split(substitute(join(getbufline(buf,1,'$'),"\n"),a:a,a:b,''),"\n",1)
	"call deletebufline(buf,1,'$')
	"call setbufline(buf,1,page)
	"DEBUG 'page: '.string(page)
endfunction

function! AutoEscapePat(a)
	DEBUG '自动转义(pat): '.a:a
	return substitute(a:a,'\(\$\)\|\(\.\)\|\(\*\)\|\(\~\)\|\(\\\)','\\&','g')
	" $ --> \$
	" . --> \.
	" * --> \*
	" ~ --> \~
	" \ --> \\
endfunction
function! AutoEscapeSub(a)
	DEBUG '自动转义(sub): '.a:a
	return substitute(a:a,'\(&\)\|\(\\\)','\\&','g')
	" & --> \&
	" \ --> \\
endfunction

let SecL=[0,0]
let SecR=[0,0]
"let b:Range=[[0,0],[line('$'),col('$')]]	NOOOOOO!!! DONOT USE THIS!
function! Search(a='')
	if a:a==''
		DEBUG '光标归位'
		echo '^^'
		call setpos('.',[bufnr(),1,1,0])
		let g:SecL=[0,0]
		let g:SecR=[0,0]
	else
		DEBUG '搜索: '.a:a
		echo '>□ '.a:a
		if searchpos(a:a,'zncW')==[1,1]
			let g:SecL=[1,1]
		else
			let g:SecL=searchpos(a:a,'zW')
		endif
		let g:SecR=searchpos(a:a,'zencW')
	endif
endfunction

function! SetL()
	DEBUG '设置前边界'
	call CheckRange()
	if g:SecL==[0,0]
		let b:Range[0]=''
	else
		let b:Range[0]=g:SecL
	endif
	echo b:Range
endfunction
function! SetR()
	DEBUG '设置后边界'
	call CheckRange()
	if g:SecR==[0,0]
		let b:Range[1]='$'
	else
		let b:Range[1]=g:SecR
	endif
	echo b:Range
endfunction
function! SetReset()
	DEBUG '重置边界'
	let b:Range=['','$']
endfunction

function! Add(a)
	DEBUG '添加文本: '.a:a
	echo '+ '.a:a
	"""""""""
endfunction
function! Del(a)
	DEBUG '删除文本: '.a:a
	echo '- '.a:a
	"""""""""
endfunction



""" File Actions
function! FILEINFO(info)
	echo '■□ '.a:info
endfunction
command! -nargs=1 -bar FILEINFO call FILEINFO(<args>)

function! OpenBlank()
	FILEINFO 'Open blank'
	" :enew won't open a new blank file while there's already one in use
	new
	let blankfile=bufnr()
	q
	execute('silent buf '.blankfile)
endfunction
function! Open(path)
	FILEINFO 'Open: '.a:path
	execute('silent open '.a:path)
endfunction

function! Save()
	let File=bufnr()
	let Filename=bufname(File)
	let Showname=Filename.'['.File.']'
	FILEINFO 'Save: '.Showname
	silent w!
	FILEINFO 'Close: '.Showname
	silent bwipe!
endfunction
function! SaveAs(path)
	let File=bufnr()
	let Filename=bufname(File)
	let Showname=Filename.'['.File.']'
	FILEINFO 'Save as: '.Showname.' --> '.a:path
	execute('silent saveas! '.a:path)
	FILEINFO 'Close: '.Showname
	execute('bwipe! '.a:path)
	execute('bwipe! '.Filename)
endfunction

function! Delete()
	let File=bufnr()
	let Filename=bufname(File)
	let Showname=Filename.'['.File.']'
	FILEINFO 'Close: '.Showname
	FILEINFO 'Delete: '.Showname
	call delete(Filename,'rf')
endfunction
function! DeletePath(path)
	FILEINFO 'Delete: '.a:path
	execute('silent! bwipe! '.a:path)
	call delete(a:path,'rf')
endfunction



echo '>>> ZeTap Engine '.ZeTap_Version.' <<<'
echo '[info] Env loaded.'
" ----------------------------------------------------------------------------------------------------



""" Check file header and then start reading this batch script.
" Headers like: [ZeTap Batch Script].<VERSION>
let Header=split(getline(1), '_')
if Header==[]
	let Header=['']
endif
if Header[0]!='[ZeTap Batch Script]'
	echo '[error] Not a ZeTap batch script. Quit.'
	finish
endif

" Read batch script
if filter(Header[1:], 'v:val=="AUTOMAKE"')==['AUTOMAKE']
	let AUTOMAKE=1
	set nomore
endif
if filter(Header[1:], 'v:val=="DEBUG"')==['DEBUG']
	let DEBUG=1
endif
let Script_Version=Header[1]
let Script_FullVersion=join(Header[1:],' -')
echo '[info] Read batch script '.Script_FullVersion.' .'
if Script_Version!=ZeTap_Version
	echo '[warning] Unmatched script version('.Script_Version.').'
endif
let Lines=line('$')
let Line=2
let RunStatus=0
"  0     : Main
" >0     : Comment Block Layers
" -1-# or $: Search
" -1- : Replace or Execute
while True()
	let Str=getline(Line)
	let Columns=strlen(Str)
	let Column=1
	if Columns!=0	" Ignore blank line.
		" Parsing this line...
		if RunStatus==0
			DEBUG '读取语句: '.Str
			if Str[Column-1]=='#'
				DEBUG '          寻找: '.Str[Column:]
				call Runnew('call Replace(Run[RunPointer][1],Run[RunPointer][2])')
				call Runarg(Str[Column:])
				let RunStatus='-1-#'
			elseif Str[Column-1]=='$'
				DEBUG '          转义寻找: '.Str[Column:]
				call Runnew('call Replace(AutoEscapePat(Run[RunPointer][1]),AutoEscapeSub(Run[RunPointer][2]))')
				call Runarg(Str[Column:])
				let RunStatus='-1-$'
			elseif Str[Column-1]=='!'
				DEBUG '          搜索: '.Str[Column:]
				call Runnew('call Search(Run[RunPointer][1])')
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			elseif Str[Column-1]=='?'
				DEBUG '          转义搜索: '.Str[Column:]
				call Runnew('call Search(AutoEscapePat(Run[RunPointer][1]))')
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			elseif Str[Column-1]=='[]'
				DEBUG '          重置范围'
				call Runnew('call SetReset()')
			elseif Str[Column-1]=='['
				DEBUG '          选取范围前边界'
				call Runnew('call SetL()')
			elseif Str[Column-1]==']'
				DEBUG '          选取范围后边界'
				call Runnew('call SetR()')
			elseif Str[Column-1]=='+'
				DEBUG '          添加文字: '.Str[Column:]
				call Runnew('call Add(Run[RunPointer][1])')
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			elseif Str[Column-1]=='-'
				DEBUG '          删除文字: '.Str[Column:]
				call Runnew('call Del(Run[RunPointer][1])')
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			elseif Str[Column-1:Column]=='//'
				DEBUG '          注释'
			elseif Str[Column-1:Column]=='/*'
				DEBUG '          注释块: 开始'
				let RunStatus=1
			elseif Str[Column-1:Column]=='::'
				DEBUG '          跳转标签: '.Str[Column+1:]
				let g:GotoDict[Str[Column+1:]]=len(Run)
				DEBUG '          GotoDict: '.string(GotoDict)
			elseif Str[Column-1]==':'
				DEBUG '          命令: '.Str[Column:]
				call Runnew(Str[Column:])
				let RunStatus='-1- '


			elseif Str[Column-1]=='<'
				if Str[Column:]==''
					DEBUG '          打开空文件'
					call Runnew('call OpenBlank()')
				else
					DEBUG '          打开文件: '.Str[Column:]
					call Runnew('call Open(Run[RunPointer][1])')
					call Runarg(Str[Column:])
				endif
			elseif Str[Column-1]=='>'
				if Str[Column:]==''
					DEBUG '          保存文件'
					call Runnew('call Save()')
				else
					DEBUG '          另存为文件: '.Str[Column:]
					call Runnew('call SaveAs(Run[RunPointer][1])')
					call Runarg(Str[Column:])
				endif

			elseif Str[Column-1]=='x'
				if Str[Column:]==''
					DEBUG '          删除文件'
					call Runnew('call Delete()')
				else
					DEBUG '          删除文件: '.Str[Column:]
					call Runnew('call DeletePath(Run[RunPointer][1])')
					call Runarg(Str[Column:])
				endif
			else
				echo '[error] Unknown command:'''.Str[Column-1].''', ignore it.'
			endif
		elseif RunStatus>0
			if Str[Column-1:Column]=='*/'
				DEBUG '          注释块: 结束'
				let RunStatus-=1
			elseif Str[Column-1:Column]=='/*'
				DEBUG '          注释块: 开始'
				let RunStatus+=1
			endif
		elseif RunStatus=='-1- '
			if Str[Column-1]==' '
				DEBUG '          （更多）: '.Str[Column:]
				call Runmore("\n".Str[Column:])
			else
				let RunStatus=0
				let Line-=1
			endif
		elseif RunStatus=='-1-#'
			if Str[Column-1]=='#'
				DEBUG '          （更多）: '.Str[Column:]
				call Runmore("\n".Str[Column:])
			elseif Str[Column-1]==' '
				DEBUG '          替换: '.Str[Column:]
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			else
				DEBUG '          替换: '.Str[Column:]
				call Runarg(Str[Column:])
				let RunStatus=0
			endif
		elseif RunStatus=='-1-$'
			if Str[Column-1]=='$'
				DEBUG '          （更多）: '.Str[Column:]
				call Runmore("\n".Str[Column:])
			elseif Str[Column-1]==' '
				DEBUG '          转义替换: '.Str[Column:]
				call Runarg(Str[Column:])
				let RunStatus='-1- '
			else
				DEBUG '          转义替换: '.Str[Column:]
				call Runarg(Str[Column:])
				let RunStatus=0
			endif
		else
			echo '[error] Unknown RunStatus:'''.RunStatus.'''.'
			let RunStatus=0
		endif
		DEBUG '内存: '.string(Run)
	endif
	" Next line
	let Line+=1
	if Line>Lines
		Break
	endif
endwhile
" Cleanwork
unlet Line
unlet Lines
unlet Column
unlet Columns
unlet Str



let RunPointer=0
DEBUG '----------------开始执行----------------'
while True()
	if RunPointer<0
		Break
	elseif RunPointer>=len(Run)
		Break
	else
		DEBUG '执行语句: '.Run[RunPointer][0]
		execute(Run[RunPointer][0])
		echo '--------------'
		if exists('b:Range')
			echo b:Range
		endif
		echo '--------------'
		let RunPointer+=1
		if exists('NextRunPointer')
			let RunPointer=NextRunPointer
			unlet! NextRunPointer
		endif
	endif
endwhile
unlet! RunPointer

if AUTOMAKE==1
	exit
endif



"let a=readfile('')
"getline(1)首行，从1开始
""" normal G转到行尾
""" strlen(getline('.'))当前行字数
"getcurpos()[1]当前行号
"line('$')
"line('.')
"col('.')
"rand()
"
"
"matchstrpos()
