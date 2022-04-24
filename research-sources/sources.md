# Research Sources:
1. Openssl Commiters Policy: https://www.openssl.org/policies/general/committer-policy.html
2. Openssl Glossary of OpenSSL terms: https://www.openssl.org/policies/glossary.html
3. Technical Policies: https://www.openssl.org/policies/technical/
4. Bylaws: https://www.openssl.org/policies/omc-bylaws.html
5. https://docs.microsoft.com/en-us/previous-versions/software-testing/cc162782(v=msdn.10)?redirectedfrom=MSDN
6. https://github.com/openssl/openssl/tree/master/fuzz

# Notes OpenSSL Policy:
- OpenSSL Management Committee (OMC) oversees all managerial and
administrative aspects of the project. The final authority for the OpenSSL project(2).
- OpenSSL Technical Committee sees all technical aspects of the project (2).
- CI (Continuous Integration) A suite of tests and checks that are run on every pull request,
commit on a daily basis (2).
- How to become a committer?
Granted by OMC (OpenSSL Management Committee) on the recommendation of OTC (1).
Can be withdrawn at any time by a vote of OMC (4). In order to retain commit
access, a commiter must have authored or reviewed at least one commit whitin
the previous two calendar quarters (4).
Expected contributors are experts in some part of the low-level crypto library as
well as generalists who contribute to all areas of the codebase (1). They
oversee the health of the project: fixing bugs, addressing open issues, reviewing
contributions, and improving tests and documentation (1). To become a commiter,
you can start by contributing code, reading code style, and getting to know
build and test system (1).
- Approval and code reviews:
    - are reviewed and approvied by at least two committers, one of whom must also be an OTC
    member. Neither of the reviewers can be the author of the submission. Only
    exception to this is during the release process where the author's review does
    count towards the two needed for automated release process and NEWS and CHANGES
    file updates.
    - In the case where two committers make a joint submission, they can review each other's
    code but not their own. Additionally, a third reviewer will be required.
    - An OMC member may apply a needs OMC decision label to a submission. An OTC member
    may also hold a needs OTC decision to a submission. An OMC decision label may be
    removed by the member that put in place the hold or by a decion of the OMC. OTC decision label may also be removed by OTC or the member that put in the hold.
    - Deployment to wild (approved submission) will only be applied after 24-hour
    deplay from approval. An exception to the delay exists for build and test breakage
    fix approvals which will be flagged with the severity: urgent label.
  (1).
- Commit workflow:
    - The public github repository is a mirror and openssl does not merge on github.
    - When someone becomes a committer, openssl will send instructions to get commit
    access to the main repository. They don't use merge commits (1).
    - `make doc-nits` should be run before submitting a pull request
    to make sure documentations have no issues.
    - Have strict design documentation in case a code changes a part of design that
    OTC must approve (https://www.openssl.org/policies/technical/design-process.html).
    - **No changes to existing public API functions and data are permitted**
    https://www.openssl.org/policies/technical/api-compat.html).
        - if necessary, a new API call can be added to implement the required
        changes in minor releases.
- Testing Policy:
    - Tests are not required for changes in :
        - documentation
        - tests suite
        - perl utilities
        - include files
        - build system
        - demos
        - refactoring
        - fixes in performance
        - changes to comments, formatting, internal naming or similar
    - Functional behavior testing (given a set of inputs it will produce
    a set of outputs).
    - Performance testing will be performanced automatically via CI on
    a regular basis for certain componented. Examples:
        - Individual algorithm performance operating over different input
        sizes
        - SSL/TLS handshake time over multiple handshakes and for different
        protocol versions and resumption/non-resumption handshake.

    - They recommend (but not mandatory) is that pull requests that
    contain significant new functionality should consider whether fuzz
    tests (systematic methodology that isued to find
    buffer overruns (remote execution); unhandled exceptions,
    read access violations (AVs), and thread hangs (permanent denial-of-service),
    and memory spikes (temporary denial-of-service) [5]) should be added.
        - refactoring does not include new tests, but they recommend
        that all corner cases are covered.
    - OpenSSL can either use LibFuzzer or AFL to do fuzzing [6].