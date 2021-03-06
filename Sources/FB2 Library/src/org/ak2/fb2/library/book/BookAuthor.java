package org.ak2.fb2.library.book;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.ak2.utils.LengthUtils;

public class BookAuthor implements Comparable<BookAuthor> {

    private String m_name;

    private String m_firstName;

    private String m_lastName;

    public BookAuthor(final String name) {
        this(name, true);
    }

    public BookAuthor(final String name, final boolean lastFirst) {
        m_name = normalize(name);
        if (LengthUtils.isNotEmpty(name)) {
            int pos = m_name.indexOf("/");
            if (pos >= 0) {
                if (lastFirst) {
                    m_lastName = m_name.substring(0, pos).trim();
                    m_firstName = m_name.substring(pos + 1).trim();
                } else {
                    m_firstName = m_name.substring(0, pos).trim();
                    m_lastName = m_name.substring(pos + 1).trim();
                }
                if (m_firstName.endsWith(".")) {
                    m_firstName = m_firstName.substring(0, m_firstName.length() - 1);
                }
                m_name = getFullName(m_firstName, m_lastName);
            } else {
                pos = m_name.lastIndexOf(' ');
                if (pos >= 0) {
                    if (lastFirst) {
                        m_lastName = m_name.substring(0, pos).trim();
                        m_firstName = m_name.substring(pos).trim();
                    } else {
                        m_firstName = m_name.substring(0, pos).trim();
                        m_lastName = m_name.substring(pos).trim();
                    }
                    if (m_firstName.endsWith(".")) {
                        m_firstName = m_firstName.substring(0, m_firstName.length() - 1);
                    }
                    m_name = getFullName(m_firstName, m_lastName);
                } else {
                    m_lastName = m_name;
                    m_firstName = null;
                }
            }
        }
    }

    public BookAuthor(final String firstName, final String lastName) {
        m_firstName = normalize(firstName);
        m_lastName = normalize(lastName);
        m_name = getFullName(firstName, lastName);
    }

    public final String getName() {
        return m_name;
    }

    public final String getFirstName() {
        return m_firstName;
    }

    public final String getLastName() {
        return m_lastName;
    }

    @Override
    public int compareTo(final BookAuthor that) {
        if (this == that) {
            return 0;
        }
        final String ln1 = this.getName();
        final String ln2 = that.getName();

        int result = ln1.compareToIgnoreCase(ln2);
        return result < 0 ? -1 : (result > 0 ? 1 : 0);
    }

    public boolean before(final BookAuthor that) {
        return this.compareTo(that) < 0;
    }

    public boolean after(final BookAuthor that) {
        return this.compareTo(that) > 0;
    }

    public boolean beforeOrSame(final BookAuthor that) {
        return this.compareTo(that) <= 0;
    }

    public boolean afterOrSame(final BookAuthor that) {
        return this.compareTo(that) >= 0;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj instanceof BookAuthor) {
            final BookAuthor that = (BookAuthor) obj;
            return LengthUtils.equals(this.m_name, that.m_name);
        }
        return false;
    }

    @Override
    public int hashCode() {
        return m_name.hashCode();
    }

    @Override
    public String toString() {
        return m_name;
    }

    public static String getFullName(final String firstName, final String lastName) {
        return (lastName + " " + firstName).trim();
    }

    public static String normalize(final String name) {
        final StringBuffer buf = new StringBuffer();
        final Pattern p = Pattern.compile("\\w+");
        final Matcher m = p.matcher(LengthUtils.safeString(name).trim());
        while (m.find()) {
            final String group = m.group();
            final String newName = group.substring(0, 1).toUpperCase() + (group.length() > 1 ? group.substring(1).toLowerCase() : "");
            m.appendReplacement(buf, newName);
        }
        m.appendTail(buf);
        return buf.toString();
    }

}
