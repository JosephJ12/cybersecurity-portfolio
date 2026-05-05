# Adding PostAuthor Model Code

Add the following code to the user model file

- Change Date: 4/26/2026
- Changed By: Joseph Jung
- File: services/community/api/models/user.go

```go
// PostAuthor model
// PostAuthor is the public-safe version of Author.
// It intentionally excludes Email, VehicleID, and createdAt fields to hide them on public pages
type PostAuthor struct {
	Nickname string `bson:"nickname" json:"nickname"`
	Picurl   string `bson:"profile_pic_url" json:"profile_pic_url"`
}
```
