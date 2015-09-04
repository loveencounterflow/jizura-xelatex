


############################################################################################################
TRM                       = require 'coffeenode-trm'
rpr                       = TRM.rpr.bind TRM
badge                     = 'XLTX'
log                       = TRM.get_logger 'plain',     badge
info                      = TRM.get_logger 'info',      badge
whisper                   = TRM.get_logger 'whisper',   badge
alert                     = TRM.get_logger 'alert',     badge
debug                     = TRM.get_logger 'debug',     badge
warn                      = TRM.get_logger 'warn',      badge
help                      = TRM.get_logger 'help',      badge
echo                      = TRM.echo.bind TRM
#...........................................................................................................
njs_fs                    = require 'fs'
njs_path                  = require 'path'
TRM                       = require 'coffeenode-trm'
CHR                       = require 'coffeenode-chr'
read                      = ( route ) -> return njs_fs.readFileSync ( njs_path.join __dirname, route ), 'utf-8'
#...........................................................................................................
TEX                       = require 'coffeenode-tex'
route_of_preamble         = '../tex-inputs/jzr2014-preamble.tex'
route_of_postscript       = '../tex-inputs/jzr2014-postscript.tex'


#===========================================================================================================
#
#...........................................................................................................
@glyph_tag_by_rsg         =
  'u-latn':                 TEX.make_command 'latin'
  'u-latn-1':               TEX.make_command 'latin'
  'u-cjk':                  TEX.make_command 'cn'
  'u-halfull':              TEX.make_command 'cn'
  'u-dingb':                TEX.make_command 'cn'
  'u-cjk-xa':               TEX.make_command 'cnxa'
  'u-cjk-xb':               TEX.make_command 'cnxb'
  'u-cjk-xc':               TEX.make_command 'cnxc'
  'u-cjk-xd':               TEX.make_command 'cnxd'
  'u-cjk-cmpi1':            TEX.make_command 'cncone'
  'u-cjk-cmpi2':            TEX.make_command 'cnctwo'
  'u-cjk-rad1':             TEX.make_command 'cnrone'
  'u-cjk-rad2':             TEX.make_command 'cnrtwo'
  'u-cjk-sym':              TEX.make_command 'cnsym' # !!! should be able to control single codepoints
  'u-cjk-strk':             TEX.make_command 'cnstrk'
  'u-pua':                  TEX.make_command 'cnjzr'
  'jzr-fig':                TEX.make_command 'cnjzr'
  'u-cjk-kata':             TEX.make_command 'ka'
  'u-cjk-hira':             TEX.make_command 'hi'
  'u-hang-syl':             TEX.make_command 'hg'
  #.........................................................................................................
  # ### TAINT kludge to accommodate for the fact that Sun-ExtA is missing a few characters: ###
  # 'xxx':                    TEX.make_command 'cnextra'

#...........................................................................................................
@stacked_fncr             = TEX.make_multicommand 'fncr', 2
#...........................................................................................................
@_py                      = TEX.make_command 'py'
@ka                       = TEX.make_command 'ka'
@hi                       = TEX.make_command 'hi'
@hg                       = TEX.make_command 'hg'
@gloss                    = TEX.make_command 'gloss'
@mainentry                = TEX.make_command 'mainentry'
@missing                  = TEX.make_command 'missing'
@hbox                     = TEX.make_command 'hbox'
@jzrplain                 = TEX.make_environment 'jzrplain'
@tabular                  = TEX.make_environment 'tabular'
# upaccent                  = TEX.make_command 'upaccent'
# aboxshift                 = TEX.make_command 'aboxshift'
#...........................................................................................................
# @par                      = ( TEX.make_loner 'par'        )()
@par                      = TEX.raw ' \\\\\n' # i.e. space, double backslash, newline
@hirabar                  = ( TEX.make_loner 'hirabar'    )()
#...........................................................................................................
# @next_cell                = TEX.raw '\n&\n'
@next_cell                = TEX.raw ' & '
# @_new_page                = ( TEX.make_loner 'newpage' )()
@new_page                 = ( TEX.make_loner 'clearpage' )()


############################################################################################################
# HELPERS
#===========================================================================================================
@tag_from_chr = ( glyph_styles, chr ) ->
  ### TAINT not well written ###
  chr_info    = CHR.analyze chr, input: 'xncr'
  { chr
    fncr
    rsg   }   = chr_info
  #.........................................................................................................
  return TEX.raw R if ( R = glyph_styles[ chr ] )?
  return TEX.raw """\\cnjzr{#{chr_info[ 'uchr' ]}}""" if rsg is 'jzr-fig'
  #.........................................................................................................
  unless ( tag = @glyph_tag_by_rsg[ rsg ] )?
    warn "unknown RSG #{rpr rsg}: #{fncr} #{chr}"
    return chr_info[ 'chr' ]
  return tag chr_info[ 'chr' ]

#-----------------------------------------------------------------------------------------------------------
@tag_rpr_from_chr = ( glyph_styles, chr ) ->
  return TEX.rpr @tag_from_chr glyph_styles, chr

#-----------------------------------------------------------------------------------------------------------
@py = ( text ) ->
  return @_py @raw @_rewrite_pinyin text

#-----------------------------------------------------------------------------------------------------------
@_rewrite_pinyin = ( text ) ->
  # return text unless text?
  # log cyan '©4p0', rpr text
  R = text
  R = R.replace /ǖ/,  "\\upaccent{\\aboxshift{ˉ}}{ü}"
  R = R.replace /ǘ/,  "\\upaccent{\\aboxshift{´}}{ü}"
  R = R.replace /ǚ/,  "\\upaccent{\\aboxshift{ˇ}}{ü}"
  R = R.replace /ǜ/,  "\\upaccent{\\aboxshift{`}}{ü}"
  R = R.replace /ê1/, "\\upaccent{\\aboxshift{ˉ}}{ê}"
  R = R.replace /ê2/, "\\upaccent{\\aboxshift{´}}{ê}"
  R = R.replace /ê3/, "\\upaccent{\\aboxshift{ˇ}}{ê}"
  R = R.replace /ê4/, "\\upaccent{\\aboxshift{`}}{ê}"
  return R


############################################################################################################
MULTIMIX = require 'coffeenode-multimix'
THIS = module.exports = MULTIMIX.compose TEX, @
@rpr                      = TEX.rpr.bind TEX

#...........................................................................................................
THIS.postscript               = THIS.raw read route_of_postscript
THIS.preamble                 = THIS.raw read route_of_preamble


