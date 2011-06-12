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

	public class ShowBlocksHelper {
		
		/**
		 * Return the CSS styles to be added to the DOM to display the blocks outline of the document.
		 */
		public function getCSS():String {
			return '.show-blocks p, .show-blocks div { padding-top: 8px; border: 1px dotted gray }';
		}
	}
}
