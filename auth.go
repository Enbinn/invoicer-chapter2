package main
import (
	"fmt"
	"net/http"
	"golang.org/x/crypto/bcrypt"
)
var demoPasswordHash []byte
func init() {
	hash, err := bcrypt.GenerateFromPassword([]byte("admin123"), bcrypt.DefaultCost)
	if err != nil {
		panic(err)
	}
	demoPasswordHash = hash
	//что-то добавил
}
func loginHandler(w http.ResponseWriter, r *http.Request) {
	password := r.FormValue("password")

	if password == "" {
		http.Error(w, "password is required", http.StatusBadRequest)
		return
	}

	err := bcrypt.CompareHashAndPassword(demoPasswordHash, []byte(password))
	if err != nil {
		http.Error(w, "invalid password", http.StatusUnauthorized)
		return
	}

	w.WriteHeader(http.StatusOK)
	fmt.Fprintln(w, "login successful")
}