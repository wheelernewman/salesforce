$(function() {

        var hsName;

        $(document).ready(function() {

            hsName = $('[id$=highSchoolSearch]').val();

            $('[id$=highSchoolSearch]').focus(function(){
                if ($('[id$=hsConfirmation]').text != '' ) {
                    $('[id$=hsConfirmation]').text('');
                }
                return false;
            });

            $('[id$=highSchoolSearch]').blur(function(){
                if ($('[id$=highSchoolSearch]').val() == '' || $('[id$=highSchoolId]').val() == ''
                    || $('[id$=highSchoolSearch]').val() != hsName) {
                    $('[id$=hsConfirmation]').text('Please select a value from the list');
                }
                return false;
            });
            return false;
        });

        // for the high school smart search
        $('[id$=highSchoolSearch]').autocomplete({
            minLength: 3, // number of characters entered before search

            source: function(request, response) { // sets the source

                var searchString = request.term;

                InstitutionEventRegistrationController.getSearchSuggestions(searchString, function(result,event) {

                    if (event.status) {
                        if (typeof result == 'undefined' || result.length <= 0) {

                            // no matches were found
                            response(['No High Schools Found']);
                        }
                        else {
                            response(result.slice(0, 10));
                        }
                    }
                    else {

                        // no response from the server
                        response(['No High Schools Found']);
                    }
                }, {escape: false});
            }, // source end

            select: function(event, ui) { // on selecting a result
                if (ui.item.label != null) {

                    hsName = ui.item.selectedLabel;

                    $('[id$=highSchoolSearch]').val(ui.item.selectedLabel);
                    $('[id$=highSchoolId]').val(ui.item.value);
                    if ($('[id$=highSchoolTextErrorMessage]').val() != null) {
                        DeleteError('');
                        $('[id$=highSchoolTextErrorMessage]').hide();
                    }
                }
                else {
                    $('[id$=highSchoolId]').val('');
                }
                return false;
            }, // select end

        });
    });
