//;-*- mode: antlr -*-
/*
                        DotParser

    Copyright (C) 2006  Jose San Leandro Armendariz
                        chous@acm-sl.org

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    Thanks to ACM S.L. for distributing this library under the GPL license.
    Contact info: chous@acm-sl.org
    Postal Address: c/Playa de Lagoa, 1
                    Urb. Valdecabanas
                    Boadilla del monte
                    28660 Madrid
                    Spain

 *****************************************************************************
 *
 * Filename: $RCSfile: DotParser.g,v $
 *
 * Author: Jose San Leandro Armendariz
 *
 * Description: Clean ANTLR-based parser to build AST according to
 *              GraphViz's Dot grammar.
 *
 * See http://www.graphviz.org/doc/info/lang.html
 *
 */
header
{
package antlr.grammars.dot;
}
class DotParser extends Parser;

options
{
    importVocab=Dot;
    buildAST=true;
    defaultErrorHandler=true;
}
{
}
graph
    :  (STRICT_LITERAL)?
       (GRAPH_LITERAL^ | DIGRAPH_LITERAL^) (ID)?
       O_BRACKET! stmt_list C_BRACKET!
    ;

protected stmt_list
    :  ( stmt SEMI_COLON! stmt_list)?
    ;

protected stmt
    {String currentId = null;}
    :  (  i:ID^ {currentId = i.getText();}
          (  EQUAL! ID
           | node_or_edge_stmt[currentId])
        | attr_stmt
        | subgraph
       )
    ;

protected node_or_edge_stmt[String id]
    { String p = null; }
    :  (p=port)?
       (  (edgeRHS) => edge_stmt[id, p]
        | node_stmt[id, p])
    ;

protected edge_stmt[String id, String port]
    :  edgeRHS (attr_list)?
    ;

protected node_stmt[String id, String port]
    :  (attr_list)?
    ;

protected attr_stmt
    :  (GRAPH_LITERAL^ | NODE_LITERAL^ | EDGE_LITERAL^) (attr_list)
    ;

protected attr_list
    :  O_SQR_BRACKET! (a_list)? C_SQR_BRACKET! (attr_list)?
    ;

protected a_list
    :  (arg) (COMMA!)? (a_list)?
    ;

protected arg
    :  ID^ (EQUAL! ID)?
    ;

protected edgeRHS
    :  EDGEOP_LITERAL (node_id | subgraph)? (edgeRHS)?
    ;

protected node_id
    { String p = null; }
    :  ID^ (p=port)?
    ;

protected port returns [String result = null]
    {String compass = null;}
    :  COLON!
        (  i:ID^ (COLON! c1:COMPASS_PT {compass = c1.getText();})?
           {
               result = i.getText();
               if  (compass != null)
               {
                   result += ":" + compass;
               }
           }
         | c2:COMPASS_PT^ { result = c2.getText(); }
        )
    ;

protected subgraph
    :  (SUBGRAPH_LITERAL^
           (  (ID) =>
                (  (O_BRACKET) => subgraph_ext
                | subgraph_simple)
            | subgraph_ext))
    ;

protected subgraph_ext
    :  (SUBGRAPH_LITERAL^ (ID)? )? O_BRACKET! stmt_list C_BRACKET!
    ;

protected subgraph_simple
    :  SUBGRAPH_LITERAL ID^
    ;
