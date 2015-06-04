# mussel + utils

## utils dependency

| command     | sum |
|:------------|----:|
| grep        | 25  |
| awk         | 15  |
| cut         |  7  |
| retry_until |  5  |

## detail

grep:

> ```
> $ git grep grep *.sh | wc -l
> 25
> ```

awk:

> ```
> $ git grep awk *.sh | wc -l
> 15
> ```

cut:

> ```
> $ git grep cut *.sh | wc -l
> 7
> ```

retry_until:

> ```
> $ git grep retry_until *.sh | wc -l
> 5
> ```
