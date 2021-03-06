package test.editors.action;

import org.eclipse.jface.action.IAction;
import org.eclipse.swt.widgets.MessageBox;
import org.eclipse.ui.IEditorActionDelegate;
import org.eclipse.ui.IEditorInput;
import org.eclipse.ui.IEditorPart;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.ActionDelegate;

import test.editors.FB2Editor;
import test.editors.document.FB2Document;

public class SplitSectionDelegate extends ActionDelegate implements IEditorActionDelegate {

	FB2Editor fieldEditor;

	public SplitSectionDelegate() {
	}

	/**
	 * @see ActionDelegate#run(IAction)
	 */
	public void run(IAction action) {
		if (fieldEditor == null || fieldEditor.getTextWidget() == null) {
			MessageBox box = new MessageBox(PlatformUI.getWorkbench().getActiveWorkbenchWindow().getShell());
			box.setMessage("Action can not be performed");
			box.open();

			return;
		}

		final IEditorInput input = fieldEditor.getEditorInput();
		if (input == null) {
			return;
		}
		int offset = fieldEditor.getTextWidget().getCaretOffset();
		final FB2Document document = (FB2Document) fieldEditor.getDocumentProvider().getDocument(input);
		document.splitSectionAtOffset(offset);
		fieldEditor.getTextWidget().redraw();
	}

	@Override
	public void setActiveEditor(IAction action, IEditorPart targetEditor) {
		if (targetEditor instanceof FB2Editor) {
			fieldEditor = (FB2Editor) targetEditor;
		}
	}
}
