# A shareholder line

From a client strategic plan doc: to a shareholder, branches and commits are numbers with no meaning.

Bad (engineer evidence in a shareholder doc):

> Merged feature/implement_sequalize (MR !73, 14 commits) moving Firestore ACLs to Sequelize on GitLab CI.

Good (the feature, plus a count that means something):

> Customer data now lives in our own database, and every client sees only their own audits. 30 guides
> and 28 videos were updated to match.

The MR number, branch and the tools go in the `-base.md` companion next to the doc.
Heading rule: write the title a person would write ("Database move"), never "Database move, the honest version".
