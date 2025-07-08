
# Leftover files from running `gen.live` for Sign

Must look over these and remove dead/unwanted code.

    └─ signbank
      ├─ dictionary.ex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ entry.ex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ form_component.ex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ index.ex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ index.html.heex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ show.ex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ show.html.heex
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ router.ex
      │  ├─ line 22: TODO : these routes are only slightly modified from `gen.live`, we don't want most of them
      │  └─ line 23: TODO : these routes are only slightly modified from `gen.live`, we don't want most of them
      ├─ dictionary_test.exs
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      ├─ entry_live_test.exs
      │  └─ line 1: TODO : this was from `gen.live`, look over it again
      └─ dictionary_fixtures.ex
          └─ line 1: TODO : this was from `gen.live`, look over it again

# Deployment automation

Just migrate stuff from previous project, don't implement the CoreOS butane stuff yet.

# DONE Implement Definitions

- [x] Uncomment relation in [sign.ex](../lib/signbank/dictionary/sign.ex)
- [x] show definitions in UI
  - [ ] style it
- [ ] create definitions in UI

# Implement `%Region{}`s

- [ ] Uncomment relation in [sign.ex](../lib/signbank/dictionary/sign.ex)

# Implement WorkflowStatus

- [ ] Add relation in [sign.ex](../lib/signbank/dictionary/sign.ex)

# Pull over Typst documentation

This is currently stored on [typst.app](https://typst.app).

# Implement videos

- [ ] upload
- [ ] basic versioning
- [ ] SignVideo model/DB migration
  - [ ] Uncomment relation in [sign.ex](../lib/signbank/dictionary/sign.ex)

# Implement `%Tag{}`s

# Consider "variant can't have definitions" DB constraint

# Remove unwanted routes from [router.ex](../lib/signbank_web/router.ex)

# Implement entry ordering (by phonology)

# Implement advanced search

Copy existing advance search options, with improvements for workflow reason

# Implement editing UI

# Implement basic entry page

- [ ] video
- [ ] variant videos (last strategy didn't work because of alpine, now that we have svelte it might work better)
- [ ] Definitions divided into categories, Trevor has given me the order the categories should go in

# Implement linguistic entry page

- [ ] three sections of fields:
  - [ ] morphology
  - [ ] semantic (???)
  - [ ] phonology
