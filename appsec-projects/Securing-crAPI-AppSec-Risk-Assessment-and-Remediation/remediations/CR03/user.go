
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
```
