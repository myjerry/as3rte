/**
 *
 * as3rte - Rich Text Editor for Adobe AIR
 * Copyright (C) 2011, myJerry Developers
 * http://www.myjerry.org/as3rte
 *
 * The file is licensed under the the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

package org.myjerry.as3rte.helper {
	
	public class RemoveFormatHelper {
		
		private const removeFormatTags:String = 'b,big,code,del,dfn,em,font,i,ins,kbd,q,samp,small,span,strike,strong,sub,sup,tt,u,var';
		
		private const removeFormatAttributes:String = 'class,style,lang,width,height,align,hspace,valign';
		
		private var tagsRegex:RegExp = new RegExp( '^(?:' + removeFormatTags.replace( /,/g,'|' ) + ')$', 'i' );
		
		private var removeAttributes:Array = removeFormatAttributes.split( ',' );
		
		public function removeFormat(selection:Object):void {
			if(selection == null) {
				return;
			}
			
			var range:Object = null;
			if(selection.rangeCount > 0) {
				range = selection.getRangeAt(0);
				
				var startNode:Object = range.startContainer;
				var endNode:Object = range.endContainer;
				
				// We need to check the selection boundaries (bookmark spans) to break
				// the code in a way that we can properly remove partially selected nodes.
				// For example, removing a <b> style from
				//		<b>This is [some text</b> to show <b>the] problem</b>
				// ... where [ and ] represent the selection, must result:
				//		<b>This is </b>[some text to show the]<b> problem</b>
				// The strategy is simple, we just break the partial nodes before the
				// removal logic, having something that could be represented this way:
				//		<b>This is </b>[<b>some text</b> to show <b>the</b>]<b> problem</b>
				
//				breakNode(startNode);
//				breakNode(endNode);
				
			}
		}
		
	}
}