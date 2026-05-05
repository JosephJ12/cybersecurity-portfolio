# New Post Model Code 

- Change Date: 4/26/2026
- Changed By: Joseph Jung
- File: services/community/api/models/post.go

```go
// Post Field
// New Post model using PostAuthor object
// removes email and vehicleID fields from previous Author object
type Post struct {
	ID        string     `gorm:"primary_key;auto_increment" json:"id"`
	Title     string     `gorm:"size:255;not null;unique" json:"title"`
	Content   string     `gorm:"size:255;not null;" json:"content"`
	Author    PostAuthor     `bson:"author" json:"author"`
	Comments  []Comments `json:"comments"`
	AuthorID  uint64     `sql:"type:int REFERENCES users(id)" json:"authorid"`
	CreatedAt time.Time
}

==========

// Prepare initialize Field
// old Author field initialization
/*
func Prepare() Author {
	var u Author
	u.Nickname = nickname
	u.Email = userEmail
	u.VehicleID = vehicleID
	u.CreatedAt = time.Now()
	u.Picurl = picurl
	return u
}
*/

// Prepare initialize Field
// new Post Author field initialization
func Prepare() PostAuthor {
	var p PostAuthor
	p.Nickname = nickname
	p.Picurl = picurl
	return p
}
```
