# Tooling for Making Textual Bible Translations

November 14, 2025

# Introduction

As Bible translation work moved onto computers in the 20th century, there was a clear benefit seen when using purpose-built software for the task rather than plain text editors or general word processors. An important development in this movement was the development of Paratext starting in 1985[^1]. As it continued to be developed and shared within the BT community, Paratext eventually became what is the most broadly used software tool for Bible translation in existence, with over 14,000 active users today[^2].

Over the course of Paratext’s history, it has gone through some significant technical changes. In the 1990s it was rewritten in Visual Basic. In the 2000s it was ported/rewritten in C\#/.NET. In the 2020s, work was started to port/rewrite it on the new Platform.Bible application using a technical framework named Electron. However, given Paratext’s size and scope after being developed for 40 years, the effort has been large and is not yet finished. The question has been asked, “Should this Platform.Bible effort continue for Paratext as its new foundation, or is there a better architectural platform or basis to use?” Certainly, there are other BT tools and frameworks in existence today.

This document was written to share lessons learned by the Paratext team in the form of requirements. These requirements should be considered for whatever tool/platform may replace Paratext 9 for textual Bible translation work.

Note that Paratext is focused on textual translations. Some oral and sign language translation teams choose to use Paratext to access exegetical resources and perhaps create a textual translation as well, but oral and sign language translations in particular are not in the scope of requirements mentioned in this document.

# People-Centric View

Paratext was written to be used by people. As such, requirements come not only in the form of “what does the software need to do?”, but also “who does the software intend to serve?”

When trying to describe who software is intended to serve, it is helpful to first think about how Bible translations are produced. While there have been cases where one or two individuals do all of the work themselves to produce a Scripture translation, this is not how things are typically done. Normally there is a larger set of people involved in some sort of workflow.

There is no one “right” workflow to produce a Bible translation. Without trying to be exhaustive in all the possible approaches discussed in the BT community as a whole, two approaches to consider here are the one reflected in SIL Language Technology’s diagram[^3] and Church and Community Based Bible Translation[^4] (CBBT) as defined by ETEN. In both of these approaches, there are some roles that are similar, and in some cases identical.

| CBBT Role[^5]                        | SIL LangTech Role | Brief Description of Similar Responsibilities                                                                     |
| :----------------------------------- | :---------------- | :---------------------------------------------------------------------------------------------------------------- |
| Translator                           | Translator        | Understands Scripture text in one language and produces draft text in the target language                         |
| Reviewer                             | Checker           | Understands the target language and looks for potential mistakes and weaknesses in a draft                        |
| Scripture Authentication Elder (SAE) | Consultant        | Someone who oversees QA activity with a focus on producing a high quality draft that adheres to translation goals |
| Team Leader                          | Project Manager   | Coordinates the work being done by people participating in the translation project                                |

It is fair to note that roles in CBBT and SIL’s Lang Tech diagram are not exactly the same. There are differences in some responsibilities and qualifications (amongst other things) for people who serve in the roles listed in the same row for each workflow. The point of the table above is to highlight important similarities between roles, not their differences. Also, there are many responsibilities not listed in the table.

The table is not meant to imply that each role is filled by a single, separate person. That may be more than one person in most roles for a translation project. Also, the same person may serve in multiple roles in a translation project.

Something that the CBBT training material does not directly discuss is how Scripture gets published for distribution, whether that be in physical or electronic form. The SIL outlined approach does touch upon some additional roles that should be considered that are related to text publishing:

- **Typesetter**: Someone who prepares a final draft for printing a physical copy or viewing on an electronic device. This involves formatting for readability by paying attention to things like spacing, fonts, alignment, etc.
- **Distributor**: Someone who distributes the final product (e.g., a printed Bible, a mobile app, etc.) that will be read by people in the target language community.
- **Archivist**: Someone who stores a version of Scripture text for reference in the future.

Here are the types of things that Paratext does for people in each of these roles. This is just a high level description of abilities. See the next section for detailed requirements of the features.

- **Translator**: Drafting support to write formatted Scripture text in the target language, simple checks to find mistakes quickly (e.g., spelling), proven resource materials that can help explain the source text meaning, and access to many other translations to see how the source text has been translated by others.
- **Reviewer/Checker**: Views of drafts with and without markers, optional task assignments to help communicate what is expected of him/her and what has been completed, and ways to communicate with others in the project through comments on the draft.
- **SAE/Consultant**: Tools to ensure consistent translation of key terms, tools to ensure correct use of language features (e.g., characters, punctuation, etc.), tools to align draft text with the source text to help verify accuracy, and ways to communicate with others in the project and related projects through comments on the drafts.
- **Team Leader/Project Manager**: Workflow management tools to assign and track progress, project permissions to allow careful delegation of abilities to those who need them, communication with others in the project through comments on the draft.
- **Typesetter**: Integration with PublishingAssistant or PTXPrint to provide many settings and styling options to create aesthetically pleasing PDFs (the PDFs are used by printing presses for producing physical copies of Scripture and electronic readers for displaying Scripture text)
- **Distributor**: Integration with ScriptureAppBuilder to create “Bible in an app” applications for mobile devices
- **Archivist**: Integration with the Digital Bible Library (DBL) for uploading completed projects for long-term storage and retrieval

In addition to the capabilities focused on specific roles, there are many things that Paratext does for all users. Some notable examples include:

- UI localized to many languages of wider communication to make the tool accessible
- Multi-lingual training & support for all levels of computer users from new to experienced
- Cloud-based services for team members to back up and share project data
- Support for BT standards like USFM and ScriptureBurrito to help people who also want to work with their project data in other tools

# Product-Centric View

The Paratext product is a full featured tool that supports the exegesis, drafting, checking and publication parts of the Bible translation value chain. In looking at the product feature set, this paper will examine several broad categories of features. The first of these areas is how the product supports drafting and exegetical research within a Scripture translation project.

## Drafting Support

### Language Support

The most core function of a Bible translation drafting platform is the editor, a software component that converts keyboard strokes into data. While a text editor may seem like a ubiquitous component available in any UI toolkit, there are many unique needs that are required for Bible translation.

In order to enter text into a system, we need to have access to a keyboard. Keyboards can be manufactured in different languages, but in order to support the wide diversity of languages on planet Earth, we have to resort to virtual keyboards. A virtual keyboard system, such as Keyman[^6], maps physical keys on a keyboard to virtual keys and allows a user to type any supported language using the virtual keyboard. Paratext provides a keyboard switching mechanism to allow a user to quickly switch from typing the target language in the main editing panel, to typing the language of wider communication in a project notes editor. Keyboard switching may require tighter integration with a keyboarding tool such as Keyman.

Once a key is typed, it must then be rendered on the computer screen by the editor component. This is done through the use of fonts. OpenType fonts support nearly all of the world’s left-to-right and right-to-left languages, but a small handful of languages still require the advanced capabilities of Graphite, a smart-font rendering system, in order to be correctly displayed on screen. By virtue of its support for Graphite, Paratext is able to meet the needs of language communities that otherwise could not be served by a tool that does not support Graphite.

Having a keyboard and a font is still not sufficient to accurately render any given language. Many languages use the same writing system, but that does not mean that they are the same. Any given language may not use the same diacritics or have the same alphabetical order. They may use punctuation differently or format large numbers using commas, spaces, or periods. Data that provides information such as this is called locale data and it is defined in a Locale Data Markup Language (LDML) file[^7]. LDML is a standard way of describing locale data and is typically stored in a repository such as the Common Locale Data Repository[^8]. A platform for Scripture editing must be able access a locale data repository and understand LDML, advanced fonts and virtual keyboard mapping.

Using Unicode, a vowel with an accent mark can be encoded using two characters (NFD), or a single combined character (NFC). A Scripture drafting editor must be able to consistently normalize and store data in either normal form decomposed (NFD), or normal form combined (NFC). Each project team needs to make this Unicode normalization choice.

### Text Editing

Text editing typically revolves around a what-you-see-is-what-you-get (WYSIWYG) editor. It is imperative that a Scripture editor show a WYSIWYG view of the data, but there is more than that needed. Scripture text is defined by the Unified Standard Format Marker (USFM) standard. The Scripture editor must be able to show or hide USFM markers so that users can see exactly what markup is being employed. When we talk about formatted views we are talking about WYSIWYG. When we talk about unformatted, or marker views, we mean displaying USFM markers and other invisible characters and whitespace.

A text editor has the following set of capabilities that are typical of most full featured editors. Editors must be able to perform cut, copy, paste, and also find and replace. These are well understood abilities but must work seamlessly with any language being displayed, normalization scheme, and any markup, whitespace and invisible characters in the text editor data. Languages that do not use spaces as word separators, such as Chinese, add an extra level of difficulty when it comes to implementing standard editor functions. We cannot simply use a stock editing component “off the shelf”.

### Internationalization/Localization

Bible translation happens all around the world and it is being done by a diverse array of language communities. In order for these diverse teams to succeed they need to be able to read the titles, menus, and messages that are a part of the software tool itself. While it is necessary for the editor to be able to display text from any language in the world, the user interface needs to be rendered in a smaller, but still significant, number of languages.

Internationalization is the term used to indicate that a software product is capable of displaying its user interface in different languages. When we talk about adding Internationalization to a software tool we are referring to the work necessary to be able to take a set of translated terms and display them in the tool itself. Instead of seeing the English words “file” and “open” you might instead see the words “dossier” and “ouvrir” in French. Localization is the process of producing a data file that accurately translates all of the words in the user interface into a different language. Paratext 9 has been localized into 33 different languages as of today.

As the user interface is localized into different languages the lengths of various UI words will change, sometimes dramatically. The UI designers need to consider at design time what will happen when labels and text areas need to grow or shrink. In addition, some languages, like English, run from left to right (LTR) while others, like Arabic, run right to left (RTL). The direction of text will have profound impacts on how a user interface is rendered on the computer screen. Modern technologies are designed to support responsive user interfaces that can grow and shrink dynamically. Good UI design ability, borne by experience with many varied languages is required.

### Navigation

The Bible is organized into many individual books such as Genesis, Psalms, Tobit, Matthew, or Revelation. These books are collected together to form the Old Testament, the New Testament, and the Deuterocanon. Different church traditions around the world define the books that make up their canon of Scripture differently. Each of these books are themselves divided into chapters and verses. This book, chapter, verse (BCV) organization provides a logical way for readers of the Bible to refer to a particular verse, and it is the way that we typically think about Bible text.

A Scripture drafting platform must be able to understand BCV navigation, and allow a user to directly access any particular BCV reference without scrolling through an extremely lengthy document. More than that, a user will typically have several different windows open at a time, and will want to scroll all of them to the same verse. This synchronized scrolling is a foundational concept for Paratext. No one would want to have to individually scroll multiple windows whenever they move to a new reference.

This concept of synchronized scrolling goes beyond Paratext, and also includes Logos[^9] and Translator's Workplace[^10]. Paratext, plus these two tools, are capable of sharing Scripture references and scrolling together as the shared Scripture reference changes.

As nice as synchronized scrolling is, there will be many times when a user wants to reference one verse in one window, and another verse in another window. In this case we will require different scroll groups to navigate independently, but keep each window in the same group synchronized. The user interface must provide a simple way of providing scroll groups, and also a simple way to change the verse reference. Finally, when the BCV is changed, the UI needs to quickly orient the user to the new reference in all other windows by highlighting the new location.

### Workspace Management

Most Bible translators work with at least two windows open at a time. Some translators work with many more than two windows open at a time. At an extreme you could have a user with a project editor, a model text, several other comparative Bible translations, a text collection, a Biblical terms renderings window, a checking results list, and a notes window. Perhaps even a Parallel Passages tool and an Interlinear as well. Managing all of these windows and making efficient use of desktop space is a true challenge.

Paratext utilizes a workspace management framework to not only provide tabs, panels, and floating windows, but also provides a way to save and share layouts with other team members. Computer screen space is precious and an excellent workspace management system is necessary.

### Real-time Collaborative Editing

Real-time collaborative editing (RCE) has grown from being rather obscure to very common over the last 20 years. This very document you are reading was created through a real-time collaborative editor that allowed the authors to instantaneously read and write text together. Paratext currently supports RCE, but only within the same geographic location.

The modern workforce is distributed. As we move toward a new platform for Paratext, it will become necessary to support a geographically distributed team with an editor that can receive real-time changes from other team members. RCE can eliminate the possibility of merge conflicts that are so prevalent and potentially difficult to resolve with asynchronous methods like Send/Receive. In fact, RCE of Scripture drafts across geographic locations was seen as valuable enough that Scripture Forge[^11] was updated in 2018 to support it (and other features).

### UX Refinement

Since the earliest days of Paratext, the tool has been built through a close relationship with Bible translators, our users. Even today the team has an unusually heavy weighting of UX specialists. These UX specialists engage in research with users to see if we are meeting their needs, and if not what we could do better. UX considerations take a prominent role in designing features and capabilities. Our team is always responding to user feedback which is gathered from within the application itself. We make it easy for users to report problems and make suggestions to our team. This focus on user experience has become an important “feature” to Paratext users.

## Exegetical Research

Bible translators need to have access to high quality Bible translations in a number of different languages in order to discover the full breadth of meaning contained in the Holy Scriptures.

The first manuscripts of the Bible were written in Hebrew, Greek, and Aramaic. These source language texts are the basis for sound research. High quality source language texts available in Paratext include the UBS Greek New Testament 5th edition, Biblia Hebraica Stuttgartensia, the Septuagint, the Byzantine New Testament, plus the Open Scriptures Hebrew Bible and the UBS Greek New Testament 4th Edition. Authoritative resources matter, and a robust library for good exegetical research will include these works and more.

In addition to source language texts, a translator needs to see translated Biblical texts in other languages they understand well. The Digital Bible Library provides 3,927 text Bibles in 2,336 languages[^12]. These texts have been generously made available to registered Paratext users. The Paratext user interface makes it simple to browse resources in a given language, click and download to view those resources.

Commentaries, Handbooks, and Consultant Notes are additional resources available to Paratext users. Commentaries seek to explain the theological interpretations of passages in the Bible. It can be very helpful for a translator to have the context and application of a passage explained at length. Handbooks are similar to a commentary in structure, but focused on issues that relate to the process of translating the passage from one language to another. A handbook may explain specific linguistic ramifications that are not necessarily related to the theological meaning of a passage. Consultant Notes are a collection of Paratext project notes that have been curated and included as a shareable set of notes. A Consultant notes project can be applied to any new translation project, and the project then has an embedded set of insight written by and for Paratext users.

An Enhanced Resource is a Bible translation in a language of wider communication that has words or phrases linked to exegetical research materials of various types. The linked material could be a Greek or Hebrew dictionary, encyclopedia articles, images, maps, or videos. The source language dictionaries are particularly rich. The user can discover semantic domains, alternate glosses, commentary and other senses of meaning of the lemma. In addition to all of this exegetical content, an enhanced resource can also link to the Biblical terms list of the user’s active translation project. An enhanced resource once linked to a project can identify words in the resource that are found or missing in the active project.

## Data Formats

### Projects

When a team is working on translating Scripture, they need some kind of structure to store the data. Raw data for each book or section being translated may go into a separate file, and there is metadata about the project that is needed to understand the relation between all the files. Paratext handles this by defining a project as a collection of related files and metadata that describe the intended work product the team is creating.

When translation teams start their work, they may have iterative goals in mind. Perhaps they first want to translate a few books, then a larger set of books, then the whole Bible. In addition, there are many branches of Christianity throughout the world, and not all of them consider the same books as part of canonical Scripture. To give teams flexibility based on their goals that might change over time, Paratext supports a customizable definition of what belongs in a particular project. Some structure is required to know what each book within a translation is intended to be (e.g., the text in this file is intended to represent the book of Genesis). So, it is important that a Scripture project both have flexibility in what books to include and clear identification of which files represent which canonical books. Paratext supports over 120 different identifiers[^13] for known books and some additional ones for peripheral support (e.g., glossaries, indices, etc.).

In addition to customizing which books are part of a translation project, there are sometimes small differences in original copies of the text found in archeological sites and copies/translations passed down through different church traditions. Sometimes one tradition will define chapter and verse breaks differently than another tradition. Simply having a different point where a verse marker should be doesn’t warrant treating the entire book as a different part of the canon. To account for this, Paratext has defined a structure called versification for a project to explicitly define the number of verses in each chapter, any verses that might be deliberately missing, how a verse might be divided into multiple segments, and how a verse from a “standard versification” maps to a different verse in this translation. Paratext has 6 standard versifications[^14] that can be used as a base. Each project can then define any differences it has with that base versification.

Other key data that is included in a project includes:

- Base translation: It is helpful to clarify if a Scripture translation project is derived from another translation. Paratext allows having explicit links between projects so that if and when a base translation is updated, the derived translations can pick up and see those changes directly instead of manually copying over the updates. This is quite helpful for projects like Study Bibles which are not focused on updating the translation but instead adding supporting material around the Scripture text to benefit readers.
- Language settings regarding the target language of the project
- Configuration options set by project leads (e.g., configuration of quality checks to run)
- Interlinear data: Data that aligns words in a translation with words in a source text.
- Key term renderings: This is data that shows how important words and phrases from the original source text are translated into the target language.
- Comments made by team members about project text
- Work assignments and progress
- Printing drafts

### Project Compatibility

Translation projects historically have taken decades to complete. Even with that process accelerating due to new tools and techniques, many projects will still likely take years to complete. Because underlying software updates will happen during the lifetime of a project and old versions of software cannot reasonably be maintained indefinitely, it is likely that project team members will need to update their software tools at some point during the project.

While tools might change, the files being modified day in and day out by the team represent the progress being made. It is critical that even as tools change, the data they are modifying remains supported. Project data must remain compatible with new software versions once a project begins or teams risk losing progress or time converting data manually.

### USFM

Unified Scripture Format Markup (USFM) was first introduced in 2002 as a way to standardize marking distinct elements within Scripture text files[^15]. There is a technical committee[^16] with members from Biblica, Bridge Connectivity Solutions, SIL, and UBS who help steer updates to USFM, including version identifiers to clarify changes over time.

USFM is intended to be both human readable and sufficiently detailed to allow computers to parse and understand the semantic type of data represented in its files. The human readability gives team members comfort, and the markup is necessary to understand how different segments of the file are intended to be seen and understood by readers.

Whenever there has been any discussion about pivoting away from making Scripture data easily available in USFM, there is great pushback from the user community. USFM support is of great importance for Paratext.

It is important to note that USFM supports not only verse text, but many supporting elements as well, including but not limited to introductory material, sidebars, footnotes, cross references, end notes, figures, and tables. Paratext must continue to support all these elements and future updates made to the USFM specification.

### Export

While Paratext projects containing USFM files are the core data formats used in Paratext, they are not always sufficient for sharing data with other tools and processes. Sometimes other tools need data not included for other reasons in Paratext projects, and sometimes other tools were just written to work with different file formats.

#### USX

The USFM committee recognized years ago that USFM isn’t a natural data format that is easy for computers to parse. In some cases, making the data easy to parse is of paramount importance. To help with that, USX and USJ were created as XML and JSON representations of USFM data.

One of the most important uses of USX is with the Digital Bible Library (DBL). The DBL requires text translations to be formatted as USX files[^17]. Paratext must be able to save projects in USX format to be shared with the DBL for archival purposes. In addition, it must be able to validate that the USX data conforms to an expected XML schema before uploading.

#### PDF

USFM files are intended to indicate the semantic type of text for some set of text (e.g., is this a verse, a side bar, a footnote, etc.). However, USFM files do not indicate what a fully rendered version of text should look like. For example, how many columns should be on a page, what spacing should be used, what font and font size should be used when printing, etc.

To share fully rendered versions of Scripture text that are ready for people to read, Paratext must be able to export data as PDF files. This is done via integration with tools like PublishingAssistant and PTXPrint which allow configuring all sorts of options for printing.

#### Scripture Burrito

Some translation teams want to use Paratext for certain capabilities but can’t or don’t want to use it for other capabilities. Because there are many tools used by people in the BT movement, and because project and data formats vary between tools, Paratext needs to be able to export projects in a way that other tools can use to import into their own formats. The Scripture Burrito format was created for this purpose in collaboration with many organizations[^18]. Paratext must continue to support this format.

### Import

For the same reason that Paratext needs to be able to export Scripture Burrito files, it also needs to be able to import Scripture Burrito files.

## Workflow Management

Distributed Bible translation teams need to be able to coordinate their work and share their project data with one another. There are several mechanisms that produce a comprehensive workflow management environment for Bible translation teams.

### Cloud Synchronization

Known as “Send/Receive” in Paratext, members of a translation project can synchronize their changes to a cloud server and download team member changes at the click of a single button. Given that this is an asynchronous method of collaboration there is the possibility of a merge conflict. In most cases merge conflicts can be resolved quickly and easily. In the case where a merge conflict is more difficult to resolve, a tool that will allow a user to compare historical versions of the project becomes necessary.

### Version Control

Version control, the ability to go back in history and manage individual changes, is a necessity for a tool that supports a collaborative team of users. A basic requirement for version control is a view of document history. The next requirement is the ability to see the differences between any two points in history. Finally, the user will need the ability to pick specific changes to “accept” or “reject”. A good version control solution needs to be able to make a complicated task appear easy to the user. Even better is to avoid merge conflicts altogether \- this is the main benefit of working online in a real-time collaborative mode. But given the nature of Bible translation around the world, having offline users in remote parts of the globe is a reality that we need to be able to accommodate. For this reason, version control tools and asynchronous S/R features are required.

### Project Comments

Distributed team members need to be able to comment on each other’s work. Adding a comment to a specific location of a vernacular Scripture text is a very convenient way of interacting. Project comments and BCV referenced, and they can be marked with an appropriate tag or icon. Notes can be assigned to a specific team member, and a team member can reply to a note, thus creating a thread of commentary about the issue described in the original note. Notes can also be marked as resolved when the purpose of the note is accomplished.

Project notes can also be applied to multiple projects at the same time. This feature is of particular benefit in a cluster project. For example, a cluster project consultant could add a note to every project in the cluster.

### Project Plans

Not every Bible translation organization works through the process of doing a Bible translation in exactly the same way. However, most organizations have a combination of Drafting, Team Checking, Consultant Review, Community Review, Final Typesetting and Publication. Paratext provides a tool for organizations to define their own project plan. Each step of the plan gets its own description, can define prerequisites, and can define the level of granularity at which it will be completed. A project plan can also define the priorities of the books to be translated in the project. Every Scripture check can be configured to be required or not, and the plan can define in which stage successfully passing the check becomes required.

### Assign Tasks

With a plan in place, a project administrator can assign tasks to specific team members. Tasks can be assigned down to a chapter level. Individual team members can look at their own tasks and thus know what they need to work on and what checks need to be passed in order to mark their task complete. As tasks are being assigned a project administrator should consider which team members need edit access to which books of the Bible. A team admin can limit access by setting User Permissions to only what is required. By limiting access to only the books that a team member requires, the chances of accidental editing conflicts can be reduced.

### Project Progress

If a team makes good use of the ability to define a plan, assign tasks, and mark them complete, then there will be good data produced to indicate the progress being made on the project and the rate at which the project is progressing. Providing manual progress data is very beneficial to systems like Progress.Bible to indicate the current status of Bible translation around the world. However, if the system relies too heavily on manual input the data could get stale. A system that can programmatically gather progress metrics directly from a project repository could, if done well, gather reliable metrics in an automated fashion and do so regularly.

## Quality Checking/Validation

No matter how Scripture drafts are created, quality checking of those drafts is a critical part of the translation process. Due to the importance of what is being conveyed in Scripture, it is important to examine the draft text from many different perspectives. It goes far beyond the effort of running a spell check and grammar check in a typical word processor.

### Rendering of Key, Biblical Terms

When translating Scripture, it is important that key concepts (sometimes called Biblical Terms in Paratext) from the source text are rendered in a consistent manner wherever possible to avoid having the translation lead to confusion by readers about the meaning of the original source text. Paratext has large lists of key terms already built in along with a mapping of those terms to where they occur in the original source text. Users can also make their own customized key term lists. It is an important exercise for the translation team to review how those terms are being translated in different parts of the translated text. Paratext does not tell the team what “good” or “correct” renderings of terms are in each location, but instead helps facilitate a thorough review by team members for consistency.

Because this can involve a lot of manual work, it is very helpful for Paratext to provide checklists of where the renderings appear to have been followed or deviated from compared to what the team already approved as appropriate. In addition, it is helpful for Paratext to display “guessed renderings” as possible based on translated text that is already in place. This can decrease how much text must be typed by the team.

### Inventories and Checks

Due to the length of Scripture and the sometimes complex nature of entering text in scripts that don’t have a standard physical keyboard, translation teams have found it helpful to inventory and verify many different aspects of the draft text. Some of the key things that are inventoried include:

- What are all the distinct characters, including whitespace and invisible characters, in the text?
- What are all the uses of punctuation within different contexts in the text? “Different contexts” refers to where the punctuation is used within a word (beginning, middle, end) or on its own.
- What are all of the distinct USFM markers used in the text?
- What are all of the cases where punctuation marks that normally come in pairs (e.g., parentheses) are left unmatched?
- What are all of the cases where capitalization of letters within a word is mixed?

Once inventories have been built for a draft of Scripture, the team can indicate which items in the inventory are expected and which items are unexpected. For example, if a draft includes an unexpected Unicode character that looks similar to a character in the target script but is different, that character would be flagged in the inventory.

After inventory items have been categorized, Paratext can generate lists of all cases where something appears to be incorrect. Team members can then correct the error or mark the deviation from the inventory as expected to exclude it from future lists.

In addition to these inventory-based checks, Paratext also has checks that run based on project or language configuration. For example, some of those important checks include:

- References (e.g., cross references) to locations that don’t exist in the translation
- Quotations that don’t appear to have been closed or continued properly based on language rules

### Interlinear View

An interlinear view is a view that runs the words of two different translations above and below one another, aligning the words with the same meaning. One reason to use an interlinear view is to allow a user to gloss the text of a project based on the corresponding text in the other translation. An interlinear view can also be used to generate a back translation, or an adaptation. The key issue in generating an interlinear view is to be able to do alignment between the two translations. One particular way to do this is to use a Biblical terms list. If two projects each have a key terms list that maps back to a common source language text, then it becomes much easier to align the words of the two projects.

### Parallel Passages

Throughout the Bible there are passages that quote or echo one another. An example is how the words of Genesis 2:24 and Matthew 19:5 say “For this reason a man will leave his father and mother…” Making this passage harmonize is an important thing to get right. The parallel passage tool is a convenient way to work through a curated list of parallelisms and see quickly if those passages in your project are identical, similar, or different from one another.

### Lexical Analysis

When working in languages that do not have predefined dictionaries, or those dictionaries do not have well-defined subsets that align with the translation goals (e.g., a list of simple words if the goal is to create a children's Bible), spell checking can be difficult.

The Wordlist tool produces a list of every word used in the translation project. Using this tool the team members can go through and mark as “approved” all words that are spelled correctly based upon the agreed orthography for the target language by the translation team. This essentially generates a basic dictionary that the project can use for spell checking.

The Wordlist tool also allows team members to define proper hyphenation of each word. The tool can break down words by morphemes and use those morphemes to provide initial guesses of correct spelling, and also initial guesses of proper hyphenation breaks.

Traditionally, Bible translators from outside of a language community had to learn the language before beginning the work of translation. This language learning process, by an expert linguist, could result in the production of a defined grammar and a dictionary. Tools like Fieldworks Language Explorer (FLEx) are perfectly suited for capturing the richness and complex nuances of the world’s languages.

During the course of a Bible translation project, a full FLEx dictionary may or may not be produced. However, producing a key terms list can give the dictionary process a jump start, and using today’s AI capabilities a fair bit of lexical data can be automatically captured during the translation project. It would be wonderful if a translation team reaches publication time, and a language dictionary is already compiled for them by the software tool.

## Environment Restrictions

Because translators and other team members are located all over the world, the environment where they can run software will vary significantly. There are a few restrictions that are important in particular:

1. Paratext must be able to run properly while not connected to a network. This might only be a temporary situation where internet access is not reliable, but it might be true for the life of a project in some sensitive areas. In these more restrictive cases, sharing project data between individuals often requires physically sharing media like USB drives.
2. Paratext must be able to work through a proxy or VPN tunnel if required. In some sensitive locations, directly connecting to certain online services would be a problem.
3. In some locations, Windows PCs are not cost effective or a platform that translators are familiar with. It is helpful for Paratext to be available through a broad set of interfaces, including Linux, macOS, Windows, the web, and mobile devices. There are other tools that fill the gap on non-Windows interfaces, but the more of these we can cover with a common tool, the more consistent the experience can be for translation teams.

## Integration With Other Tools and Resources

When we talk about Paratext at a high level, we sometimes talk about the Paratext ecosystem, not just Paratext. While Paratext does a lot, no one tool can do everything. It is important for Paratext users to be able to easily tap into the benefits of the larger ecosystem.

### External Services

Some of the most innovative services today for translation teams are AI tools like Project Slingshot[^19] and AQuA[^20]. Because AI services are usually hosted in the cloud instead of running locally on a computer, there are problems to solve like getting project data to the services in addition to configuring and running those services.

Paratext’s primary method of communicating with other services has been through the sharing of project files via the Send/Receive server. This generally involves users opening web browsers to websites for those services. Because this creates extra burdens for service providers that integrate with Paratext and complicates the user experience, future versions of Paratext should make API connectivity between Paratext and those services straightforward. Service providers should be able to directly communicate from and create custom UI within Paratext for their services. That would allow users to use these services without leaving Paratext.

### Access to More Resources

There are thousands of existing translations and other exegetical resources that exist to help with drafting translations. It is important for translators to be able to easily access those resources. This is often done by downloading existing translations from the DBL in addition to downloading related projects made available from the Send/Receive server. Once downloaded, those resources can be opened and kept in sync within the UI using a shared BCV reference between the project and resources.

It is important for translators to be able to see many different resources at once for the same BCV. This requires a compact UI to show all these resources together at once.

### Extensibility of the Tool

There are many ideas from users and partners about how to make Paratext more useful to translation teams. Also, several tool and content providers have asked how they can add their content and functionality to Paratext.

Paratext should allow developers from anywhere to create customized additions that a user could run in their copy of Paratext. These customized additions could do anything: workflow automation for tasks unique to a translation organization, advanced analysis of draft text, integration with other tools in the BT space, and more.

Beyond just adding to Paratext’s functionality, Paratext should allow content providers to share useful content (e.g., exegetical resources they created) with other Paratext users. Paratext should make it simple to add more resources to its library of content, understanding that content providers will need to use standardized formats. Those formats may be navigable by BCV along with Scripture content, but they should not all be required to be structured like that.

## Training and support of the tool

A software product, without a supportive community, will not be widely used. Users need to learn to use the tool, and they need to have a safe place to ask questions. Users also need a safe place to make suggestions and describe problems that they encounter. In return, the development team needs to be able to understand the problems, and offer meaningful solutions. All of this requires appropriate communications avenues.

One of the best ways to learn to use a large, full featured tool is to attend a live workshop. It is incredibly helpful to have another person explain a concept to you, and be available to help you learn it hands on. Workshops also help users to build a network of other users that they can ask questions of later. The Paratext development team has made a habit of sending software developers to training workshops so that they can hear from users first hand, and also perhaps, be able to answer some questions themselves.

The next best way to learn a software feature is to see it done in a video. Videos can show you exactly what the feature looks like in use, and they allow the user to pause, rewind and watch again. Well done explainer videos are very valuable.

The third tier of educational support is a written manual. Sometimes it's just good to be able to look up a precise issue and read it. Written documentation that communicates accurately and concisely takes time to produce. But if done well it can be very valuable.

An online forum can produce a community that answers one another’s questions. Over time, the forum will produce a history of answered questions which becomes a valuable resource in its own right. Forums require dedication on the part of one or more staff members to regularly go to the forum and answer questions.

In a situation like a cluster project, if all teams use the same software tooling, then they can become a support resource for one another. One member of the cluster may have forgotten how to use the interlinier tool, but a neighbor might be able to help them out. In a situation where there are multiple tools in use, this benefit gets lost. But as more teams and users have a shared expertise the ability to find solutions among themselves increases.

A User Advisory Committee can serve as an excellent top down way of highlighting shared problems and advocating for prioritized solutions. A robust tool platform should be looking to involve their user community from the top down as well as from the grass roots up.

# Room For Improvement

While Paratext has been a very useful tool to help translation teams create new translations, it is by no means perfect. Here are some key things that should be addressed:

- Some users passionately ask for Linux and macOS support. Paratext 9 only runs on Windows due to its use of WinForms. WinForms apps cannot provide cross-platform compatibility (Linux, macOS, and Windows).
- WinForms does not support the UI patterns and interactions which make software usable today. Also, the mix of WinForms and outdated HTML controls presents technical barriers and vulnerabilities.
- Many tool and content providers have helpful resources for translators and consultants. Those providers want to share their resources with Paratext users, but they find it very difficult to embed the content inside of Paratext 9\. At the same time, Paratext users have said repeatedly that they don’t want “yet another tool” to open while they work. Screen space is at a premium, and it is hard to mentally juggle many tools at once.
- A number of UI choices in Paratext 9 have presented user experience problems such as expansive menus, lack of accessibility, onboarding challenges due to the lack of a starting point for new users and projects, difficulty of integrating new tools that aren’t structured around navigation by Scripture location, and high UI localization costs.
- Students graduating from university are increasingly unlikely to have any exposure to building and maintaining WinForms applications. For long-term sustainability, it is important to have access to a large pool of developers who have experience with and interest in the technology used to power strategically important projects.
- Paratext 9 targets .NET Framework 4.8. .NET Framework 1.0 was released in 2002, 4.8 in 2019, and the final minor update (4.8.1) in 2022\. Microsoft has no further development work planned for the .NET Framework. While no end-of-life date has been announced yet, it is inevitable that .NET Framework will be deprecated since it is no longer actively developed.
- Source code for Paratext 9 is not open source which is a concern for some partners.

# Maximizing Reuse Of Existing Code

As mentioned in the introduction, people have been writing code for Paratext for 40 years. It has gone through two major technical updates, and it is due for another. However, because Paratext has so much existing code, it is impractical to think that the entire application could be efficiently and faithfully rewritten on a totally different technical foundation from scratch. It would be too expensive and take too long. Some effort must be taken to carry forward as much existing code as possible while still achieving the goal of creating a new foundation that will meet Paratext’s needs for many years to come.

While it may not be the only approach, it seems likely that new Paratext versions will require running a .NET process in some way. While .NET Framework seems to be on life support, Microsoft has not abandoned the .NET platform entirely. Parts of .NET continue to be updated, and the Paratext team has worked to consolidate many of its features into libraries that other .NET processes can load. This means applications running .NET processes on Linux, macOS, and Windows can run the same logic that Paratext 9 does today (for some features).

# Future Considerations

The requirements in this document represent some of the institutional knowledge gained within UBS and SIL through creating, maintaining, improving, and supporting Paratext for decades. Although Bible translation is decentralized, the Paratext team is fortunate to have been able to help translate God’s word into over 3000 languages. Much has been learned in the process.

It is fair to question whether the lessons of the past will continue to apply to the future. For example, will AI make all BT work obsolete by just doing everything for us? Also, will changes in BT workflows like CBBT make current roles so outdated that they no longer apply in any way?

While BT work has and will certainly continue to change, we believe many lessons from the past will continue to apply in the future. This is because:

- The point of translating Scripture isn’t just about having something to read for a language group. Even if technology could produce a new, high quality translation with the push of a button, we want the translation process to be transformative for the people involved and for the passion it sparks to spread to the community who receives translated Scripture. The process of grappling with hard problems during translation leads team members to grow in their knowledge of God’s word and His character. In addition, the shared work and accomplishment of producing a translation can be part of the process of Scripture engagement within a community.
- A machine cannot take responsibility for work. Computers and technology are tools in the hands of people, and people will stay involved in the translation process. Also, machines will make mistakes, and we will need to QA draft text no matter where it originates.
- Even as BT workflows change, many of the core activities seem to remain unchanged. It is mostly a question of how the activities are accomplished and who is responsible for them. New techniques are unlikely to mean the notion of iteratively producing drafts, putting them through some QA process, and refining them is going to change.

One high-level lesson from building and maintaining Paratext is that you can’t sit still. The methods and tools of Bible translation have changed a lot over the last 50 years and will continue to change. Paratext needs to keep changing with it to stay relevant while not forgetting lessons from the past.

# Conclusion

Paratext has many, many capabilities that have been built and refined over the years. Users have told us the features are necessary to produce high quality Scripture translations. At the same time, the current tech stack for Paratext has been working for about 20 years. Its shortcomings are being felt, and the question at hand is what is an appropriate foundation that could last another 20 years.

# References

## Appendix A: “Value Chain” Diagram from SIL’s LTCon in 2024

This diagram was removed for brevity.

[^1]: [https://paratext.org/about/history/](https://paratext.org/about/history/)

[^2]: [https://paratext.org/](https://paratext.org/)

[^3]: See Appendix A

[^4]: [https://www.etenlab.org/\_files/ugd/046448_6b8b0f2659dc49588a0af9618e7b6829.pdf](https://www.etenlab.org/_files/ugd/046448_6b8b0f2659dc49588a0af9618e7b6829.pdf)

[^5]: [Manual for CBBT Course 1](https://docs.google.com/document/d/1SgGqjxoj2XPiUPVsYNG-oxRtFs4akxZbv12SVO75WDE/edit?tab=t.0#heading=h.e11bwfwa49ux)

[^6]: [https://keyman.com/](https://keyman.com/)

[^7]: [https://unicode.org/reports/tr35/](https://unicode.org/reports/tr35/)

[^8]: [https://cldr.unicode.org/](https://cldr.unicode.org/)

[^9]: [https://www.logos.com/](https://www.logos.com/)

[^10]: [https://www.sil.org/resources/publications/tw](https://www.sil.org/resources/publications/tw)

[^11]: [https://scriptureforge.org/](https://scriptureforge.org/)

[^12]: [https://library.bible/](https://library.bible/)

[^13]: [https://github.com/sillsdev/libpalaso/blob/master/SIL.Scripture/Canon.cs\#L226](https://github.com/sillsdev/libpalaso/blob/master/SIL.Scripture/Canon.cs#L226)

[^14]: [https://github.com/sillsdev/libpalaso/blob/master/SIL.Scripture/Versification.cs\#L1340](https://github.com/sillsdev/libpalaso/blob/master/SIL.Scripture/Versification.cs#L1340)

[^15]: [https://docs.usfm.bible/](https://docs.usfm.bible/)

[^16]: [https://github.com/usfm-bible/tcdocs](https://github.com/usfm-bible/tcdocs)

[^17]: [https://care.library.bible/article/188-text-formatting](https://care.library.bible/article/188-text-formatting)

[^18]: [https://docs.burrito.bible/en/latest/](https://docs.burrito.bible/en/latest/)

[^19]: [https://etenlab.notion.site/](https://etenlab.notion.site/)

[^20]: [https://ai.sil.org/projects/AQuA](https://ai.sil.org/projects/AQuA)
