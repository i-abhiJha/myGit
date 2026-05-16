# myGit — A Mini Version Control System in C++

A from-scratch reimplementation of Git's core internals in modern C++. `myGit`
implements Git's content-addressable object model — blobs, trees, and commits keyed
by SHA-1 — with zlib-compressed object storage, a staging index, a parent-linked
commit history, and working-tree restoration via `checkout`.

The goal of the project is to understand *how Git actually works under the hood*,
rather than to be a Git replacement.

## Highlights

- **Content-addressable storage** — every object is stored under
  `.mygit/objects/<first 2 hex>/<remaining hash>`, exactly like Git.
- **SHA-1 integrity hashing** via OpenSSL for blobs, trees, and commits.
- **zlib compression** of all stored objects.
- **Staging index** (`add`) and **commit graph** with parent links (`log`).
- **Recursive tree reconstruction** on `checkout` to restore the working directory
  to any commit.
- **Modular architecture** with a clean parse → dispatch → encode pipeline.

## Architecture

```
argv ──> inputHandler ──> command (dispatch) ──> encoder ──> .mygit/ object store
         (parse args)     (init/add/commit/…)    (SHA-1 + zlib)
```

| File              | Responsibility                                                        |
|-------------------|-----------------------------------------------------------------------|
| `main.cpp`        | Entry point; wires parser → dispatcher.                                |
| `inputHandler.cpp`| Parses CLI arguments into a `Command { command, params }`.             |
| `command.cpp`     | Implements every subcommand (init, add, commit, log, checkout, …).     |
| `encoder.cpp`     | SHA-1 hashing, zlib (de)compression, object read/write.                |
| `common.h`        | Shared declarations, the `Command` struct, and path constants.         |

## Build

### Prerequisites

- A C++20 compiler (`g++`)
- **OpenSSL** (`-lssl -lcrypto`) — SHA-1 hashing
- **zlib** (`-lz`) — object compression

On macOS: `brew install openssl zlib`
On Debian/Ubuntu: `sudo apt install libssl-dev zlib1g-dev`

### Compile

```bash
make            # builds ./mygit
make clean      # removes build artifacts and the .mygit/ store
make install    # installs ./mygit to /usr/local/bin (optional)
```

## Usage

```bash
./mygit init                              # create a .mygit/ repository

echo -n "hello world" > test.txt
./mygit hash-object -w test.txt           # store a blob, print its SHA-1
./mygit cat-file -p <sha>                 # print object contents by hash

./mygit add .                             # stage files for the next commit
./mygit commit -m "Your commit message"   # record a commit
./mygit log                               # walk the commit history

./mygit write-tree                        # snapshot the directory as a tree object
./mygit ls-tree --name-only <tree_sha>    # list a tree's entries
./mygit checkout <commit_sha>             # restore the working tree to a commit
```

## Commands

| Command       | Description                                                         |
|---------------|---------------------------------------------------------------------|
| `init`        | Create the hidden `.mygit/` directory that tracks repository state.  |
| `hash-object` | Compute a file's SHA-1; with `-w`, store it as a compressed blob.    |
| `cat-file`    | Print an object's contents or metadata by its SHA-1.                 |
| `write-tree`  | Capture the current directory structure as a tree object.           |
| `ls-tree`     | List a tree object's entries (`--name-only` for names only).         |
| `add`         | Stage files or directories into the index.                          |
| `commit`      | Create a commit object from the staged index (`-m` for message).     |
| `log`         | Walk and display the commit history from `HEAD`.                     |
| `checkout`    | Restore the working directory to a specific commit.                  |

## What I Learned

- How Git's object model (blob / tree / commit) composes into a versioned history.
- Building content-addressable storage, and why hashing gives integrity *and*
  deduplication for free.
- Working with binary formats, zlib streams, and OpenSSL SHA-1 in C++.
- Recursive directory serialization and reconstruction for tree checkout.

## License

Educational project — free to read, learn from, and extend.
