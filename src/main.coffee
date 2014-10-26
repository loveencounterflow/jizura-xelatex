


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
  'u-cjk':                  TEX.make_command 'cn'
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
  #.........................................................................................................
  ### TAINT kludge to accommodate for the fact that Sun-ExtA is missing a few characters: ###
  'xxx':                    TEX.make_command 'cnextra'

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

#-----------------------------------------------------------------------------------------------------------
@_glyph_tag_from_chr_info = ( chr_info ) ->
  ### TAINT not well written ###
  if chr_info[ 'csg' ] is 'u' and 0x9fbc <= chr_info[ 'cid' ] <= 0x9fcc
    rsg = 'xxx'
  else
    rsg = chr_info[ 'rsg' ]
  tag = @glyph_tag_by_rsg[ rsg ]
  unless tag?
    warn "unknown RSG #{rpr rsg}"
    return chr_info[ 'chr' ]
  return tag chr_info[ 'chr' ]

############################################################################################################
# HELPERS
#===========================================================================================================
@tag_from_chr = ( chr ) ->
  ### TAINT not well written ###
  chr_info  = CHR.analyze chr, input: 'xncr'
  rsg       = chr_info[ 'rsg' ]
  if rsg is 'jzr-fig'
    # return TEX.raw """\\cnjzr{\\symbol{"#{chr_info[ 'cid' ].toString 16}}}"""
    return TEX.raw """\\cnjzr{\\symbol{#{chr_info[ 'cid' ]}}}"""
  else
    return @_glyph_tag_from_chr_info chr_info

  # #.......................................................................................................
  # if TEXT.starts_with glyph, '&'
  #   [ ignore
  #     rsg
  #     cid_hex ] = glyph.match ///^ & ( [a-z]+ ) \#x ( [0-9a-fA-F]+ ) ; $///
  #   # log rsg, cid_hex
  #   cid         = new_integer cid_hex, 16
  #   sfncr       = "jzr/#{cid_hex}"
  #   fncr        = "jzr/#{cid_hex}"
  #   glyph       = UNICODE.chr_from_cid  cid
  # #.......................................................................................................
  # else
  #   cid         = CHR.as_cid            glyph
  #   rsg         = CHR.rsg_from_cid      cid
  #   cid_hex     = NUMBER.as_hexadecimal cid, width: 5
  #   sfncr       = CHR.as_sfncr          cid
  #   fncr        = CHR.as_fncr           cid
  # #.......................................................................................................
  # R =
  #   'glyph':    glyph
  #   'rsg':      rsg
  #   'cid-hex':  cid_hex
  #   'cid':      cid
  #   'sfncr':    sfncr
  #   'fncr':     fncr
  # #.......................................................................................................
  # tag = glyph_tag_by_rsg[ rsg ]
  # #.......................................................................................................
  # if tag?
  #   R[ 'tex-tag' ] = tag glyph
  # else
  #   R[ 'tex-tag' ] = ᵡmissing glyph
  #   log red "no tag found for #{fncr} #{glyph}"
  # #.......................................................................................................
  # return R

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


