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

package org.myjerry.as3rte {
	
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	
	import mx.controls.Alert;
	import mx.controls.HTML;
	import mx.events.FlexEvent;
	import mx.events.RSLEvent;
	
	import org.myjerry.as3rte.helper.ShowBlocksHelper;
	
	public class RichTextHTML extends HTML {
		
		private var _myDocument:Object;
		
		private var showBlocksStyleSheet:Object = null; 
		
		protected function get myDocument():Object {
			return this._myDocument;
		}
		
		override public function initialize():void {
			super.initialize();
			this.addEventListener(FlexEvent.CREATION_COMPLETE, completeInitialization);
			this.htmlText = '<html><body></body></html>';
		}
		
		private function reset():void {
			myDocument.body.innerHTML = "";
			this.showBlocksStyleSheet = null;
		}

		/**
		 * Called when component creation is complete
		 */		
		private function completeInitialization(event:FlexEvent):void {
			this._myDocument = this.htmlLoader.window.document;
			
			myDocument.designMode="on";
			myDocument.open();
			myDocument.write('Hello World!');
			myDocument.close();
			
			// Set basic fonts on the control to look good
			addStyleSheet("body { font-family: Arial, Helvetica, sans-serif; font-size: 12px;}");
		}
		
		/**
		 * Returns the HTML source of the rich text
		 */
		public function get source():String {
			if(myDocument != null) {
				return myDocument.body.innerHTML as String;
			} else {
				return "";
			}
		}
		
		/**
		 * Actual functions follow
		 */
		
		/**
		 * Toggles the BOLD behavior of the current selection or the text entry point
		 */
		public function doBold():void {
			execCommand('bold');
		}
		
		/**
		 * Toggles the ITALIC behavior of the current selection or the text entry point
		 */
		public function doItalic():void {
			execCommand('italic');
		}
		
		/**
		 * Toggles the UNDERLINE behavior of the current selection or the text entry point
		 */
		public function doUnderline():void {
			execCommand('underline');
		}
		
		/**
		 * Function to create a new URL
		 */
		public function insertLinkInText(url:String):void {
			execCommand('createlink', true, url);
		}
		
		/**
		 * Function to add the given image
		 */
		public function insertImage(url:String):void {
			execCommand('insertImage', true, url);
		}

		/**
		 * Delete the existing contents and create a new page
		 */
		public function newPage():void {
			reset();
		}
		
		/**
		 * Cut the current contents of the control and copy them to the clipboard as PLAIN TEXT.
		 */
		public function cutContent():void {
			var selection:Object = getSelection();

			// copy the content to the clipboard as well
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, selection.toString());

			// delete the contents
			var range:Object = selection.getRangeAt(0);
			range.deleteContents();
		}
		
		/**
		 * Copy the contents of the control to the clipboard as PLAIN TEXT.
		 */
		public function copyContent():void {
			var selectedText:String = getSelection().toString();
			
			// var range:* = this.htmlLoader.window.createRange();
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, selectedText);
		}
		
		/**
		 * Paste the contents of the clipboard into the control as PLAIN TEXT.
		 */
		public function pasteContent():void {
			// check if the clipboard has some data
			// if not, we plainly exit
			var textToBePasted:Object = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT);
			if(textToBePasted == null) {
				return;
			}
			
			// yes, we have data
			// remove any current existing selection
			var selection:Object = getSelection();
			var range:Object = selection.getRangeAt(0);
			
			// now insert the text at the current location
			const textNode:Object = myDocument.createTextNode(textToBePasted as String);
			range.insertNode(textNode);
		}
		
		/**
		 * Paste the contents of the clipboard into the control as PLAIN TEXT.
		 */
		public function pasteContentAsPlainText():void {
			// check if the clipboard has some data
			// if not, we plainly exit
			var textToBePasted:Object = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT);
			if(textToBePasted == null) {
				return;
			}
			
			// yes, we have data
			// remove any current existing selection
			var selection:Object = getSelection();
			try {
				var range:Object = selection.getRangeAt(0);
				
				// now insert the text at the current location
				const textNode:Object = myDocument.createTextNode(textToBePasted as String);
				range.insertNode(textNode);
			} catch(e:Error) {
				// can happen if we are not selected at any position
			}
		}
		
		/**
		 * Paste the contents of the clipboard (copied in MS WORD format) into the control as rich text.
		 */
		public function pasteContentFromWord():void {
			// Microsoft word drops the content as HTML text as well on the clipboard
			// pick that up as well
			var htmlToBePasted:Object = Clipboard.generalClipboard.getData(ClipboardFormats.HTML_FORMAT);
			if(htmlToBePasted == null) {
				return;
			}
			
			// clean the MS word specific pseudo-code
			var cleanHTML:String = cleanupMicrosoftTags(htmlToBePasted as String);
			
			// we have data
			// insert this data into the editor
			execCommand('inserthtml', false, cleanHTML);
		}
		
		public function printContents():void {
			notYetImplemented();
		}
		
		public function spellCheckContents():void {
			notYetImplemented();
		}

		public function undo():void {
			execCommand('undo');
		}
		
		public function redo():void {
			execCommand('redo');
		}
		
		public function selectAllContent():void {
			execCommand('selectall');
		}
		
		public function removeFormatting():void {
			var nodes:Array = getNodesInSelection();
			if(nodes != null && nodes.length > 0) {
				var startNode:Object = nodes[0];
				var endNode:Object = nodes[nodes.length - 1];
				
				// We need to check the selection boundaries (bookmark spans) to break
				// the code in a way that we can properly remove partially selected nodes.
				// For example, removing a <b> style from
				//		<b>This is [some text</b> to show <b>the] problem</b>
				// ... where [ and ] represent the selection, must result:
				//		<b>This is </b>[some text to show the]<b> problem</b>
				// The strategy is simple, we just break the partial nodes before the
				// removal logic, having something that could be represented this way:
				//		<b>This is </b>[<b>some text</b> to show <b>the</b>]<b> problem</b>
				breakNode(startNode);
				if(startNode != endNode) {
					breakNode(endNode);
				}
				
				// now for each of the nodes, start the cleaning up operation
				for each(var node:Object in nodes) {
					removeFormattingFromNode(node);
				}
			}
		}
		
		protected function breakNode(node:Object, offset:int = -1):void {
			
		}
		
		protected function removeFormattingFromNode(node:Object):void {
			
		}
		
		public function strikeThrough():void {
			execCommand('strikethrough');
		}
		
		public function subScript():void {
			execCommand('subscript');
		}
		
		public function superScript():void {
			execCommand('superscript');
		}
		
		public function insertRemoveNumberedList():void {
			execCommand('insertorderedlist');
		}
		
		public function insertRemoveUnorderedList():void {
			execCommand('insertunorderedlist');
		}
		
		public function decreaseIndent():void {
			notYetImplemented();
		}
		
		public function increaseIndent():void {
			execCommand('indent');
		}
		
		public function blockQuote():void {
			var selection:Object = getSelection();
			var range:Object = null;
			if(selection.rangeCount > 0) {
				range = selection.getRangeAt(0);
				if(range != null) {
					var element:Object = createElement('blockquote');
					var commonNode:Object = range.commonAncestorContainer;
					commonNode.parentNode.insertBefore(element, commonNode);
					commonNode.parentNode.removeChild(commonNode);
					element.appendChild(commonNode);
				}
			}
		}
		
		public function createDIVContainer():void {
			notYetImplemented();
		}
		
		public function leftAlign():void {
			execCommand('justifyleft');
		}
		
		public function centerAlign():void {
			execCommand('justifycenter');
		}
		
		public function rightAlign():void {
			execCommand('justifyright');
		}
		
		public function justifyAlign():void {
			execCommand('justifyfull');
		}
		
		public function insertHorizontalRule():void {
			execCommand('inserthorizontalrule');
		}
		
		public function unlink():void {
			execCommand('unlink');
		}
		
		public function insertAnchor(anchorName:String):void {
			notYetImplemented();
		}
		
		public function insertPageBreak():void {
			notYetImplemented();
		}
		
		public function showHideBlocks():void {
			// if we do not have the 'show blocks' CSS loaded - push this in queue
			// depending on whether we are in show or hide mode
			// add/remove the class name from the body attribute
			// this will add the class name to all elements of the page
			if(this.showBlocksStyleSheet == null) {
				// we need to retain the object to make sure that we remove it 
				// when a user wants to hide the blocks
				this.showBlocksStyleSheet = addStyleSheet(new ShowBlocksHelper().getCSS());
				
				addClass('show-blocks');
			} else {
				// remove the class
				removeClass('show-blocks');
				
				// and the stylesheet as well
				removeStyleSheet(this.showBlocksStyleSheet);
				this.showBlocksStyleSheet = null;
			}
		}
		
		private function notYetImplemented():void {
			Alert.show('not yet implemented');
		}

		/**
		 * Utility function to execute a command on the HTML DOM object, helps in re-using the
		 * DOM's rich-text editing capabilities.
		 */
		protected function execCommand(commandName:String, useDefaultUI:Boolean = false, value:* = null):Boolean {
			if(value != null) {
				return myDocument.execCommand(commandName, useDefaultUI, value);
			} else {
				return myDocument.execCommand(commandName);
			}
		}
		
		/**
		 * Function to clean up Microsoft WORD specific tags and classes from the HTML
		 * string.
		 */ 
		protected function cleanupMicrosoftTags(htmlToClean:String):String {
			var cleanHTML:String = htmlToClean;
			return cleanHTML;
		}
		
		/**
		 * Delete's the user selection and returns it back to be handled in
		 * the callee function.
		 */
		protected function deleteSelection():Object {
			var selection:Object = getSelection();
			
			// copy the content to the clipboard as well
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, selection);
			
			// delete the contents
			var range:Object = selection.getRangeAt(0);
			range.deleteContents();
			
			return selection;
		}
		
		/**
		 * Adds the given class name to the HTML BODY className attribute.
		 */
		protected function addClass(className:String):void {
			var c:String = myDocument.body.className;
			if(c) {
				var regex:RegExp = new RegExp('(?:^|\\s)' + className + '(?:\\s|$)', '');
				if(!regex.test(c)) {
					c += ' ' + className;
				}
			}
			myDocument.body.className = c || className;
		}
		
		/**
		 * Removes the given class name from the HTML BODY className attribute.
		 */
		protected function removeClass(className:String):void {
			var c:String = myDocument.body.className;
			if(c) {
				var regex:RegExp = new RegExp( '(?:^|\\s+)' + className + '(?=\\s|$)', 'i' );
				if(regex.test(c)) {
					c = c.replace(regex, '').replace( /^\s+/, '');
				}
				if(c) {
					myDocument.body.className = c;
				} else {
					myDocument.body.className = '';
				}
			}
		}
		
		/**
		 * Returns the current user selection
		 */
		protected function getSelection():Object {
			return this.htmlLoader.window.getSelection();
		}
		
		/**
		 * Create a new element on the HTML DOM
		 */
		protected function createElement(elementName:String):Object {
			return myDocument.createElement(elementName);
		}
		
		/**
		 * Creates a new element out of the style sheet text and returns
		 * the generated style sheet object.
		 */
		protected function addStyleSheet(cssText:String):Object {
			var stylesheet:Object = myDocument.createElement("style");
			if(stylesheet != null) {
				stylesheet.type = 'text/css';
				stylesheet.textContent = cssText;
				var documentHead:Object = myDocument.getElementsByTagName('head')[0];
				documentHead.appendChild(stylesheet);
				return stylesheet;
			}
			
			return null;
		}
		
		/**
		 * Removes a previously created style sheet from the document
		 */
		protected function removeStyleSheet(styleSheet:Object):void {
			if(styleSheet != null) {
				var documentHead:Object = myDocument.getElementsByTagName('head')[0];
				documentHead.removeChild(styleSheet);
			}
		}
		
		/**
		 * Convenience function that returns an array of all nodes as in the current selection
		 */
		protected function getNodesInSelection():Array {
			var selection:Object = getSelection();
			if(selection != null && selection.rangeCount > 0) {
				var range:Object = selection.getRangeAt(0);
				return getNodesInRange(range);
			}
			
			return null;
		}
		
		/**
		 * Get all nodes as an array from the given RANGE DOM object.
		 * Modelled around http://stackoverflow.com/questions/667951/how-to-get-nodes-lying-inside-a-range-with-javascript
		 */
		protected function getNodesInRange(range:Object):Array {
			var startNode:Object = range.startContainer.childNodes[range.startOffset] || range.startContainer;//it's a text node
			var endNode:Object = range.endContainer.childNodes[range.endOffset] || range.endContainer;
			
			if (startNode === endNode && startNode.childNodes.length === 0) {
				return [ startNode ];
			};
			
			var nodes:Array = new Array();
			do {
				nodes.push(startNode);
			} while (startNode = getNextNode(startNode, endNode));
			
			return nodes;
		}
		
		/**
		 * Helper method to find the next node from a given node
		 */
		protected function getNextNode(node:Object, endNode:Object, skipChildren:Boolean = false):Object {
			//if there are child nodes and we didn't come from a child node
			if(endNode === node) {
				return null;
			}
			
			if (node.firstChild && !skipChildren) {
				return node.firstChild;
			}
			
			if (!node.parentNode){
				return null;
			}
			return node.nextSibling || getNextNode(node.parentNode, true);
		}
	}
}
