# Linguistics Crash Course
This document very roughly outlines some linguistic concepts that are present in the Signbank codebase. Its goal is not to give you a comprehensive understanding of these linguistic concepts, but instead to give you enough of a cursory understanding that you can navigate the Signbank codebase more confidently. Additionally, it is important to note that these terms originally referred to spoken and written language, and have been adapted to signed languages.

### Phonology
In linguistics, phonology refers to the organisation of the *sounds* that make up words. Words are made up of *phonemes*; the smallest possible sounds that can be put together to construct the word. In the case of signed languages, the equivalent structures are:
- **Handshape**: The shape(s) the hand assumes during a sign. In `RED`, this is `ONE`.
- **Orientation**: The rotation of the hand/direction of the palm when signing. In `RED`, this is to the `Left` of the signer.
- **Location**: The location of the hand relative to the rest of the body during a sign. In `RED`, this is on the `Mouth or lips` of the signer.
- **Movement**: The movement(s) the hands undergo during the sign. In `RED`, this is a `Side-to-side` `Circular` movement.
- Expression: The expression(s) the signer's face takes on during the sign.

#### In the Database
These elements are expressed in the `phonology` column of the `signs` table as `Dictionary.Phonology`s in the Ecto schema.

### Vocabulary
Vocabulary refers to the particular regions/groups of speakers which may use a given sign. Signbank contains fields for the regional dialects, relationships with other sign languages, and iconicity/folklore status of the sign.

#### Iconicity
Iconicity indicates how much the form of the sign relates to the meaning. An opaque sign is one that is arbitrary (as almost all English words are), where a transparent one has a form that clearly indicates its meaning.

Possible values: Opaque → Obscure → Translucent → Transparent

Iconicity data in Auslan Signbank are based on lexicographer judgement.

### Semantics
In linguistics, semantics refers to the *meaning* of words. In the sign editing UI, signs are assigned 'semantic categories'; areas to which the sign pertains. The full list of semantic categories is in the database table `semantic_categories`, and signs are related to them through the join table `signs_semantic_categories`, as it is possible for a sign to occupy several semantic categories at once.

### Morphology
A **directional sign** is one that can be moved around the signing space.

A **begin-directional** sign can vary its start location but has a defined ending location.

An **end-directional** sign has a defined starting location but can vary its start location.

An **orientating** sign has varied orientation (c.f. `look` swivel)

A **locating** sign (c.f., grab-grab, placing instead of moving)

A **body locating** sign (c.f., operation can be signed on the head for a brain operation)

A sign's morphology is represented in the database as a `Dictionary.Morphology` embedding.

## Glosses
A gloss is an English word representing a sign. It is *not* the name, title, or equivalent English word for a sign, simply a shorthand English term to make referring to the sign in English more easy.

# Background/Assorted Information
Homophone was to facilitate video reuse (less important now that storage is quite cheap)

Sense is for homophones

Needs to be something on the screen that shows that there is a homophonic sign

These fields are ling information:
- dirtf
- begindirtf
- enddirtf
- orienttf
- bodyloctf
- locdirtf

Compound is you can see all signs

Blend is when it is less obvious

**Initialization** is when the first letter handshape is included in the form of the sign

**Idiom** just lists the words in the idiom

Calque, same meaning as for spoken languages--a word or phrase borrowed by literally translating from the source language, e.g. the English 'flea market' comes from the French 'marche aux puces', meaning market with fleas.

## Design notes for future Signbank UIs
Make the headsign video larger, make all of the videos larger.

Clearly delineate the linguistic and lay views of signs.

The order of the signs should be phonological and it should be possible to page through the signs as if browsing an English dictionary alphabetically.

## Definitions
The sort order UI allows you to reorder definitions within each category, but it is not possible to mix nouns and verbs freely, they always show up in their respective categories.
