# Copyright 2013-present Barefoot Networks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set (P4_FRONTEND_SRCS
  p4/frontend.cpp
  p4/createBuiltins.cpp
  p4/def_use.cpp
  p4/validateParsedProgram.cpp
  p4/symbol_table.cpp
  p4/toP4/toP4.cpp
  p4/callGraph.cpp
  p4/typeChecking/typeChecker.cpp
  p4/typeChecking/bindVariables.cpp
  p4/typeChecking/typeConstraints.cpp
  p4/typeChecking/typeUnification.cpp
  p4/typeChecking/syntacticEquivalence.cpp
  p4/strengthReduction.cpp
  p4/unusedDeclarations.cpp
  p4/evaluator/evaluator.cpp
  p4/evaluator/substituteParameters.cpp
  p4/parserControlFlow.cpp
  p4/reservedWords.cpp
  p4/modelInstances.cpp
  p4/externInstance.cpp
  p4/methodInstance.cpp
  p4/parserCallGraph.cpp
  p4/tableApply.cpp
  p4/simplify.cpp
  p4/substitution.cpp
  p4/substitutionVisitor.cpp
  p4/fromv1.0/programStructure.cpp
  p4/fromv1.0/converters.cpp
  p4/typeMap.cpp
  p4/simplifyDefUse.cpp
  p4/sideEffects.cpp
  p4/simplifyParsers.cpp
  p4/uniqueNames.cpp
  p4/resetHeaders.cpp
  p4/moveDeclarations.cpp
  p4/tableKeyNames.cpp
  p4/specialize.cpp
  p4/uselessCasts.cpp
  p4/directCalls.cpp
  p4/setHeaders.cpp
  )

set (P4_FRONTEND_HDRS
  p4/callGraph.h
  p4/cloner.h
  p4/coreLibrary.h
  p4/createBuiltins.h
  p4/def_use.h
  p4/enumInstance.h
  p4/evaluator/evaluator.h
  p4/evaluator/substituteParameters.h
  p4/externInstance.h
  p4/fromv1.0/converters.h
  p4/fromv1.0/programStructure.h
  p4/fromv1.0/v1model.h
  p4/frontend.h
  p4/methodInstance.h
  p4/moveDeclarations.h
  p4/parameterSubstitution.h
  p4/parserCallGraph.h
  p4/parserControlFlow.h
  p4/reservedWords.h
  p4/resetHeaders.h
  p4/sideEffects.h
  p4/simplify.h
  p4/simplifyDefUse.h
  p4/simplifyParsers.h
  p4/specialize.h
  p4/strengthReduction.h
  p4/substitution.h
  p4/substitutionVisitor.h
  p4/symbol_table.h
  p4/tableApply.h
  p4/toP4/toP4.h
  p4/typeChecking/bindVariables.h
  p4/typeChecking/syntacticEquivalence.h
  p4/typeChecking/typeChecker.h
  p4/typeChecking/typeConstraints.h
  p4/typeChecking/typeUnification.h
  p4/typeMap.h
  p4/uniqueNames.h
  p4/unusedDeclarations.h
  p4/tableKeyNames.h
  p4/validateParsedProgram.h
  p4/uselessCasts.h
  p4/directCalls.h
  p4/setHeaders.h
  )


set (COMMON_FRONTEND_SRCS
  common/options.cpp
  common/constantFolding.cpp
  common/resolveReferences/referenceMap.cpp
  common/resolveReferences/resolveReferences.cpp
  common/parseInput.cpp
  common/constantParsing.cpp
  )

set (COMMON_FRONTEND_HDRS
  common/constantFolding.h
  common/constantParsing.h
  common/model.h
  common/name_gateways.h
  common/options.h
  common/parseInput.h
  common/programMap.h
  common/resolveReferences/referenceMap.h
  common/resolveReferences/resolveReferences.h
  )


set (V1_FRONTEND_SRCS
  p4-14/typecheck.cpp
  p4-14/header_type.cpp
  )

set (IR_DEF_FILES ${IR_DEF_FILES} ${CMAKE_CURRENT_SOURCE_DIR}/p4-14/ir-v1.def PARENT_SCOPE)

set (V1_FRONTEND_HDRS
  p4-14/header_type.h
  p4-14/inline_control_flow.h
  p4-14/typecheck.h
  )

set (PARSERS_SRCS
  parsers/parserDriver.cpp
  )

set (PARSER_HDRS
  parsers/parserDriver.h
  )

macro(add_parser pname)
  add_custom_target (mk${pname}dirs
    ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/parsers/${pname})
  BISON_TARGET (${pname}Parser parsers/${pname}/${pname}parser.ypp ${CMAKE_CURRENT_BINARY_DIR}/parsers/${pname}/${pname}parser.cpp)
  # regardless of the output name, flex puts out yy.lex.c, so we use a custom command to generate
  # the file to stdout and redirect to the desired name
  # FLEX_TARGET (${pname}Lexer parsers/${pname}/${pname}lexer.ll ${CMAKE_CURRENT_BINARY_DIR}/parsers/${pname}/${pname}lexer.cc)
  set (FLEX_${pname}Lexer_OUTPUTS ${CMAKE_CURRENT_BINARY_DIR}/parsers/${pname}/${pname}lexer.cc)
  add_custom_command (OUTPUT ${FLEX_${pname}Lexer_OUTPUTS}
    COMMAND ${FLEX_EXECUTABLE} -t ${CMAKE_CURRENT_SOURCE_DIR}/parsers/${pname}/${pname}lexer.ll > ${FLEX_${pname}Lexer_OUTPUTS}
    DEPENDS ${BISON_${pname}Parser_OUTPUTS}
    COMMENT "Running Flex on parsers/${pname}")

  set (${pname}PARSER_GEN_SRCS
    ${FLEX_${pname}Lexer_OUTPUTS}
    ${BISON_${pname}Parser_OUTPUTS}
    )
endmacro(add_parser)

add_parser(v1)
add_parser(p4)

# BUILT_SOURCES += \
# 	parsers/p4/p4parser.hpp \
# 	parsers/v1/v1parser.hpp

# noinst_HEADERS += \
# 	parsers/p4/p4lexer.hpp \
# 	parsers/v1/v1lexer.hpp

set (FRONTEND_SOURCES
  ${COMMON_FRONTEND_SRCS}
  ${PARSERS_SRCS}
  ${P4_FRONTEND_SRCS}
  ${V1_FRONTEND_SRCS}
  ${p4PARSER_GEN_SRCS}
  ${v1PARSER_GEN_SRCS}
  ${IR_GENERATED_SRCS}
  )

set_source_files_properties(${IR_GENERATED_SRCS} PROPERTIES GENERATED TRUE)
set_source_files_properties(${v1PARSER_GEN_SRCS} PROPERTIES GENERATED TRUE)
set_source_files_properties(${p4PARSER_GEN_SRCS} PROPERTIES GENERATED TRUE)
add_library (frontend STATIC ${FRONTEND_SOURCES} ${EXTENSION_FRONTEND_SOURCES})
add_dependencies (frontend genIR)
add_dependencies (frontend mkp4dirs mkv1dirs)

set (FRONTEND_CPPLINT_FILES
  ${P4_FRONTEND_SRCS} ${P4_FRONTEND_HDRS}
  ${COMMON_FRONTEND_SRCS} ${COMMON_FRONTEND_HDRS}
  ${V1_FRONTEND_SRCS} ${V1_FRONTEND_HDRS}
  ${PARSERS_SRCS} ${PARSERS_HDRS})
add_cpplint_files (${CMAKE_CURRENT_SOURCE_DIR} "${FRONTEND_CPPLINT_FILES}")
