package org.ak2.fb2.library.book;

import java.io.CharArrayWriter;
import java.io.UnsupportedEncodingException;
import java.util.HashMap;
import java.util.Map;

import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.ak2.fb2.library.book.image.FictionBookImage;
import org.ak2.utils.XmlUtils;
import org.ak2.utils.jlog.JLogLevel;
import org.ak2.utils.jlog.JLogMessage;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;

public class FictionBook extends FictionBookInfo {

    private final String fieldEncoding;

    private final Document fieldDocument;

    private Map<String, FictionBookImage> fieldImages;

    public FictionBook(final XmlContent content) throws Exception {
        super(XmlUtils.selectNode(content.getDocument(), "/FictionBook/description"));
        fieldDocument = content.getDocument();
        fieldEncoding = content.getEncoding();
    }

    public Document getDocument() {
        return fieldDocument;
    }

    public int getImageIndex(final String imageFileName) {
        final FictionBookImage[] images = getImages();
        for (int i = 0; i < images.length; i++) {
            final FictionBookImage image = images[i];
            if (image.getImageFileName().equals(imageFileName)) {
                return i;
            }
        }
        return -1;
    }

    public FictionBookImage getImage(final String imageFileName) {
        return getImageMap().get(imageFileName);
    }

    public String[] getImageFileNames() {
        final Map<String, FictionBookImage> imageMap = getImageMap();
        return imageMap.keySet().toArray(new String[imageMap.size()]);
    }

    public FictionBookImage[] getImages() {
        final Map<String, FictionBookImage> imageMap = getImageMap();
        return imageMap.values().toArray(new FictionBookImage[imageMap.size()]);
    }

    protected Map<String, FictionBookImage> getImageMap() {
        if (fieldImages == null) {
            fieldImages = new HashMap<String, FictionBookImage>();
            if (fieldDocument != null) {
                int index = 0;
                for (final Node node : XmlUtils.selectNodes(fieldDocument, "/FictionBook/binary")) {
                    final Element element = (Element) node;
                    try {
                        final FictionBookImage image = new FictionBookImage(element);
                        fieldImages.put(image.getImageFileName(), image);
                        index++;
                    } catch (final Throwable th) {
                        new JLogMessage(JLogLevel.ERROR, "Image {0} cannot be loaded: ").log(th, index);
                    }
                }
            }
        }
        return fieldImages;
    }

    public byte[] getBytes() throws TransformerFactoryConfigurationError, TransformerException {
        final CharArrayWriter buffer = new CharArrayWriter();
        final DOMSource source = new DOMSource(fieldDocument);
        final StreamResult result = new StreamResult(buffer);
        final TransformerFactory f = TransformerFactory.newInstance();
        final Transformer t = f.newTransformer();
        t.transform(source, result);
        return toBytes(buffer);
    }

    private byte[] toBytes(final CharArrayWriter output) {
        final String text = output.toString();
        try {
            return text.getBytes(fieldEncoding);
        } catch (final UnsupportedEncodingException ex) {
            return text.getBytes();
        }
    }

}
