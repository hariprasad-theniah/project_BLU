import re 

in_file= '/Users/hariprasadtheniah/git-repos/personal/project_BLU/sample_files/sascodes/macros/logreport.sas'
outfile = '/Users/hariprasadtheniah/git-repos/personal/project_BLU/sample_files/output/logreport.py'

outfile_ref = open(outfile, 'w')

macro_keyword_initials = ['%macro','%let','%if', '%else', '%global','%do','%end','%mend','%put', '%\\*']
macro_keyword_others   = ['%then','%to','%while', '%until']
macro_functions        = [   '%sysfunc', '%qsysfunc', '%bquote', '%nrbquote', '%nrquote', '%nrstr', '%quote', '%superq', '%str', '%eval', '%index', '%length'
                           , '%scan' ,'%qscan', '%substr', '%qsubstr', '%symexist', '%symglobal', '%symlocal', '%sysevalf', '%sysget', '%sysmacexec', '%sysmacexist'
                           , '%sysmexecdepth', '%sysmexecname', '%sysprod', '%unquote', '%upcase', '%qupcase'
                         ]

symbol_table = {}

indent = 0

lines = []

compbl = lambda inpValue:re.sub(' +',' ',inpValue)

check_keyword_initials = lambda inpValue:True if len([iList for iList in macro_keyword_initials if len(re.findall('(^{:s} ?.*)'.format(iList),inpValue,re.IGNORECASE)) > 0]) > 0 else False

def break_line(pLine, pWordList):
    rLines = []
    pCLine = pLine
    for iList9 in pWordList:
        if pLine.find(iList9) > -1:
            pCLine[0:pLine.find(iList9)]


# check_macro_calls = lambda inpValue:
# check_keyword_initials_test = lambda inpValue:[iList for iList in macro_keyword_initials if len(re.findall('(^{:s} .*)'.format(iList),inpValue,re.IGNORECASE)) > 0]

# def check_keyword_initials_test(inpValue):
#     for iList in macro_keyword_initials:
#         print(inpValue," => ",'(^{:s} ?.*)'.format(iList))
#         print(re.findall('(^{:s} ?.*)'.format(iList),inpValue.lower(),re.IGNORECASE))
        
    
# def check_quote_funcs(inpValue):
#     if re.findall('%quote()')

with open(in_file, 'r') as infile_ref:
    for iLine in infile_ref:
        if iLine.strip('\n').strip() == '':
            pass 
        else:
            lines.append(compbl(iLine.replace('\n',' ')).strip())

lines = ' '.join(lines)
lines = lines.split(';')

print(lines)

lines_copy = []
for iRange in list(range(len(lines))):
    if iRange == 0:
        lines_copy.append(lines[iRange].strip())
    else:
#         check_keyword_initials_test(lines[iRange].strip())
#         print(check_keyword_initials_test(lines[iRange].strip()))
#         print(check_keyword_initials(lines[iRange].strip()))
        if check_keyword_initials(lines[iRange].strip()):
            lines_copy.append(lines[iRange].strip())
        else:
            lines_copy[len(lines_copy) - 1] += ';' + lines[iRange].strip()
            
for i in lines_copy:
    print(i)
    macro_calls = re.findall('(%[_A-Za-z]{1}[_A-Za-z0-9]*)',i,re.IGNORECASE)
    print([iList9 for iList9 in macro_calls if iList9.lower() not in macro_keyword_initials + macro_keyword_others + macro_functions])
    
# mac_vars = []

# for iList in lines:
#     print(re.findall('(%let[ \n]+)',iList, re.IGNORECASE))
#     if len(re.findall('(%let[ \n]+)',iList, re.IGNORECASE)) > 0:
#         mac_vars
#         print(re.findall('(%let[ \n]+)',iList, re.IGNORECASE))

# print(lines)

outfile_ref.close()

