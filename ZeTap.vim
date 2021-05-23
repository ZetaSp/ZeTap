" ZeTap - THE Translation Auto Processor
" Maintainer:	Zetaspace <ideaploter@outlook.com>
" Version:	0.2.0 Alpha
" Last Update:	2021 May 23



let DEBUG=0
let AUTOMAKE=0
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
let True=1
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
let GotoDict={'SOF':0, 'EOF':-1}
let RunPointer=-1 "Not running.
function! To(lable)
	if g:RunPointer>=0
		let g:GotoDict[a:lable]=g:RunPointer
	else
		echo '[error] Out of the virtual machine.'
	endif
endfunction
function! Goto(lable)
	if g:RunPointer>=0
		if haskey(g:GotoDict,a:lable)
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
"   Create:The LABLE
" Goto <LABLE>
"   Use:It
"
" Available: 	INSIDE the virtual machine.
" Preprocess:	'::' at code start will be pre-processed as LABLEs.
" 	e.g.	::LABLE1
" Overwrite: 	Always.



""" Run.Manager
let Run=[]
function! Runnew(data)
	let g:Run+=[[a:data.'']]
endfunction
function! Runadd(data)
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
"nmap echo :echo Run<enter>		"Test only.
"nmap clean :let Run=[]<enter>		"Test only.



""" Core Actions
function! Replace(a,b)
	DEBUG '替换: '.a:a.' --> '.a:b
	echo '□■ '.a:a.' --> '.a:b
	for item in g:Files
		let buf=bufnr(item)
		call bufload(buf)
		let page=split(substitute(join(getbufline(buf,1,'$'),"\n"),a:a,a:b,''),"\n",1)
		call deletebufline(buf,1,'$')
		call setbufline(buf,1,page)
		DEBUG 'page: '.string(page)
	endfor
endfunction

function! AutoEscape(a)
	DEBUG '自动转义: '.a:a
	return substitute(substitute(a:a,'\','\\\\','g'),'&','\\\&','g')
endfunction



""" Files Actions
function! FILEINFO(info)
	echo '■□ '.a:info
endfunction
command! -nargs=1 -bar FILEINFO call FILEINFO(<args>)

let Files=[]
function! Open(path)
	DEBUG '          打开: '.a:path
	FILEINFO 'Open: '.a:path
	execute('silent drop '.a:path)
	let g:Files+=[a:path]
	call uniq(sort(g:Files))
endfunction

function! Clopen(path)
	DEBUG '          切换: '.a:path
	call CloseAll()
	call Open(a:path)
endfunction

function! Save(path)
	DEBUG '          保存: '.a:path
	FILEINFO 'Close: '.a:path
	update!
	call filter(g:Files, 'v:val!=a:path')
endfunction
function! SaveAll()
	DEBUG '          全部保存'
	if g:Files!=[]
		FILEINFO 'Save all'
		update!
		let g:Files=[]
	endif
endfunction

function! Close(path)
	DEBUG '          关闭: '.a:path
	FILEINFO 'Close: '.a:path
	update!
	execute('bdelete! '.a:path)
	call filter(g:Files, 'v:val!=a:path')
endfunction
function! CloseAll()
	DEBUG '          全部关闭'
	if g:Files!=[]
		FILEINFO 'Close all'
		update!
		execute('bdelete! '.string(g:Files))
		let g:Files=[]
	endif
endfunction

function! Delete(path)
	DEBUG '          删除: '.a:path
	FILEINFO 'Delete: '.a:path
	execute('bdelete! '.a:path)
	call delete(a:path)
	call filter(g:Files, 'v:val!=a:path')
endfunction
function! DeleteAll()
	DEBUG '          全部删除: '.string(g:Files)
	if g:Files!=[]
		FILEINFO 'Delete all'
		execute('bdelete! '.string(g:Files))
		call delete(g:Files)
		let g:Files=[]
	endif
endfunction

function! Backup(path)
	DEBUG '          备份: '.a:path
	FILEINFO 'Backup: '.a:path
	execute('silent !copy '.a:path.' '.a:path.'.bak /Y')
	redraw!
endfunction
function! BackupAll()
	DEBUG '          全部备份'
	if g:Files!=[]
		FILEINFO 'Backup all'
		for item in g:Files
			execute('silent !copy '.item.' '.item.'.bak /Y')
			redraw!
		endfor
	endif
endfunction

function! Restore(path)
	DEBUG '          恢复: '.a:path
	FILEINFO 'Restore: '.a:path
	execute('bdelete! '.a:path)
	execute('silent !copy '.a:path.'.bak '.a:path.' /Y')
	redraw!
	execute('silent drop '.a:path)
	bufdo e!
endfunction
function! RestoreAll()
	DEBUG '          全部恢复'
	if g:Files!=[]
		FILEINFO 'Restore all'
		for item in g:Files
			execute('bdelete! '.item)
			execute('silent !copy '.item.'.bak '.item.' /Y')
			redraw!
			execute('silent drop '.item)
		endfor
		bufdo e!
	endif
endfunction



echo '[info] Env loaded.'
" ----------------------------------------------------------------------------------------------------



""" Check file header and then start reading this batch file.
" Headers like: [ZeTap Batch File].<VERSION>
let Header=split(getline(1), '_')
if Header[0]!='[ZeTap Batch File]'
	echo '[error] Not a ZeTap batch file.'
else
" Read batch file
	if filter(Header[1:], 'v:val=="AUTOMAKE"')==['AUTOMAKE']
		let AUTOMAKE=1
		set nomore
	endif
	if filter(Header[1:], 'v:val=="DEBUG"')==['DEBUG']
		let DEBUG=1
	endif
	let Lines=line('$')
	let Line=2
	echo '[info] Reading ZeTap batch file '.join(Header[1:],' -')
	let RunStatus=0		"  0     : Main
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
					DEBUG '          搜索: '.Str[Column:]
					call Runnew('call Replace(Run[RunPointer][1],Run[RunPointer][2])')
					call Runadd(Str[Column:])
					let RunStatus='-1-#'
				elseif Str[Column-1]=='$'
					DEBUG '          搜索: '.Str[Column:]
					call Runnew('call Replace(Run[RunPointer][1],AutoEscape(Run[RunPointer][2]))')
					call Runadd(Str[Column:])
					let RunStatus='-1-$'
				elseif Str[Column-1]=='?'
					DEBUG '          搜索: '.Str[Column:]
					call Runnew('call search(Run[RunPointer][1])')
					call Runadd(Str[Column:])
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
				elseif Str[Column-1:Column]=='<<'
					if Str[Column+1:]==''
						echo '[error] Open nothing, ignore it.'
					else
						DEBUG '          打开文件: '.Str[Column+1:]
						call Runnew('call Open(Run[RunPointer][1])')
						call Runadd(Str[Column+1:])
					endif
				elseif Str[Column-1]=='<'
					if Str[Column:]==''
						echo '[error] Open nothing, ignore it.'
					else
						DEBUG '          切换文件: '.Str[Column:]
						call Runnew('call Clopen(Run[RunPointer][1])')
						call Runadd(Str[Column:])
					endif
				elseif Str[Column-1]=='>>'
					if Str[Column:]==''
						DEBUG '          保存所有文件: '.Str[Column+1:]
						call Runnew('call SaveAll()')
					else
						DEBUG '          保存文件: '.Str[Column+1:]
						call Runnew('call Save(Run[RunPointer][1])')
						call Runadd(Str[Column+1:])
					endif
				elseif Str[Column-1]=='>'
					if Str[Column:]==''
						DEBUG '          关闭所有文件: '.Str[Column:]
						call Runnew('call CloseAll()')
					else
						DEBUG '          关闭文件: '.Str[Column:]
						call Runnew('call Close(Run[RunPointer][1])')
						call Runadd(Str[Column:])
					endif
				elseif Str[Column-1]=='x'
					if Str[Column:]==''
						DEBUG '          删除所有文件: '.Str[Column:]
						call Runnew('call DeleteAll()')
					else
						DEBUG '          删除文件: '.Str[Column:]
						call Runnew('call Delete(Run[RunPointer][1])')
						call Runadd(Str[Column:])
					endif
				elseif Str[Column-1]=='b'
					if Str[Column:]==''
						DEBUG '          备份所有文件: '.Str[Column:]
						call Runnew('call BackupAll()')
					else
						DEBUG '          备份文件: '.Str[Column:]
						call Runnew('call Backup(Run[RunPointer][1])')
						call Runadd(Str[Column:])
					endif
				elseif Str[Column-1]=='r'
					if Str[Column:]==''
						DEBUG '          恢复所有文件: '.Str[Column:]
						call Runnew('call RestoreAll()')
					else
						DEBUG '          恢复文件: '.Str[Column:]
						call Runnew('call Restore(Run[RunPointer][1])')
						call Runadd(Str[Column:])
					endif
				else
					echo '[error] Unknown command:'''.Str[Column-1].''', ignore it.'
				endif
			elseif RunStatus>0
				if Str[Column-1:Column]=='*/'
					DEBUG '          注释块: 开始'
					let RunStatus-=1
				elseif Str[Column-1:Column]=='/*'
					DEBUG '          注释块: 结束'
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
					call Runadd(Str[Column:])
					let RunStatus='-1- '
				else
					DEBUG '          替换: '.Str[Column:]
					call Runadd(Str[Column:])
					let RunStatus=0
				endif
			elseif RunStatus=='-1-$'
				if Str[Column-1]=='$'
					DEBUG '          （更多）: '.Str[Column:]
					call Runmore("\n".Str[Column:])
				elseif Str[Column-1]==' '
					DEBUG '          转义替换: '.Str[Column:]
					call Runadd(Str[Column:])
					let RunStatus='-1- '
				else
					DEBUG '          转义替换: '.Str[Column:]
					call Runadd(Str[Column:])
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
endif



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
		let RunPointer+=1
	endif
endwhile
call CloseAll()
unlet RunPointer



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
