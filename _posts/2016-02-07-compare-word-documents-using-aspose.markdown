---
layout: post
title: compare word documents using aspose
date: 2016-02-07 22:26:00 +0000
tags: development aspose
---

As part of the project I'm currently working on we are generating word documents. We use [Aspose.Words](http://www.aspose.com/.net/word-component.aspx) for the ease of automation. In version [15.2.0](http://www.nuget.org/packages/Aspose.Words/15.2.0) built-in document comaprison was introduced. This came to a great relief since...

Don't mock third-party libraries
--------------------------------
> There are two problems when mocking a third-party library. First, you can't use the tests to drive the design, the API belongs to someone else. Mock-based tests for external libraries often end up contorted and messy to get through to the functionality that you want to exercise. These tests are giving off smells that highlight designs that are inappropriate for your system but, instead of fixing the problem and simplifying the code, you end up carrying the weight of the test complexity. The second issue is that you have to be sure that the behaviour you implement in a mock (or stub) matches the external library. How difficult this is depends on the API, which has to be specified (and implemented) well enough for you to be certain that the tests are meaningful. - [Steve Freeman](http://www.mockobjects.com/2007/04/test-smell-everything-is-mocked.html)

Moving to end-to-end testing has allowed us to integrate early, assert on results we would expect when running in production, and enabled to get rid of layers of abstractions.

Code to compare two word documents
----------------------------------

{% highlight csharp %}
class Program
{
    static void Main(string[] args)
    {
        var generated = new Document(@"generated.docx");
        var expected = GetUpToDateExpectedDocument();

        var differences = Compare(generated, expected);
    }

    // update word fields (e.g., current date)
    private static Document GetUpToDateExpectedDocument()
    {
        var expected = new Document(@"expected.docx");
        expected.UpdateFields();
        return expected;
    }

    // compare method mutates generated document by adding revisions
    private static int Compare(Document generated, Document expected)
    {
        generated.Compare(expected, "Integration Test", DateTime.Now);
        return CountDifferences(generated.Revisions);
    }

    private static int CountDifferences(RevisionCollection revisions)
    {
        var differences = 0;
        foreach (Revision revision in revisions)
        {
            differences++;
        }
        return differences;
    }
}
{% endhighlight %}
